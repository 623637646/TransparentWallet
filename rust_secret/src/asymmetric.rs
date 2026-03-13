use crate::{KEY_LENGTH_16, KEY_LENGTH_32, nonce::generate_nonce, symmetric};
use hkdf::Hkdf;
use rkyv::{Archive, Deserialize, Serialize};
use sha2::Sha256;
use x25519_dalek::{EphemeralSecret, PublicKey, StaticSecret};
use zeroize::Zeroize;

const DERIVATION_KEY: &[u8] = b"derivation_key";

#[derive(Archive, Deserialize, Serialize, Debug, PartialEq, Clone)]
#[rkyv(compare(PartialEq), derive(Debug))]
pub(crate) struct EncryptedData {
    salt: [u8; KEY_LENGTH_16],
    public_key: [u8; KEY_LENGTH_32],
    encrypted_data: symmetric::EncryptedData,
}

pub(crate) fn encrypt(other_public_key: &[u8; KEY_LENGTH_32], plaintext: &[u8]) -> EncryptedData {
    let other_public_key = PublicKey::from(*other_public_key);
    // generate public and private key
    let private_key = EphemeralSecret::random();
    let public_key = PublicKey::from(&private_key);

    // generate shared secret
    let mut shared_secret = private_key.diffie_hellman(&other_public_key);

    // generate symmetric key
    let salt = generate_nonce();
    let hk = Hkdf::<Sha256>::new(Some(&salt), shared_secret.as_bytes());
    shared_secret.zeroize();
    let mut key_bytes = [0u8; KEY_LENGTH_32];
    hk.expand(DERIVATION_KEY, &mut key_bytes).unwrap();

    // encrypt symmetric
    let encrypted_data = symmetric::encrypt(&key_bytes, plaintext);
    key_bytes.zeroize();

    EncryptedData {
        salt,
        public_key: public_key.to_bytes(),
        encrypted_data,
    }
}

pub(crate) fn decrypt(
    other_private_key: &[u8; KEY_LENGTH_32],
    encrypted_data: &EncryptedData,
) -> Option<Vec<u8>> {
    let public_key = PublicKey::from(encrypted_data.public_key);

    // generate shared secret
    let private_key = StaticSecret::from(*other_private_key);

    let mut shared_secret = private_key.diffie_hellman(&public_key);

    // generate symmetric key
    let hk = Hkdf::<Sha256>::new(Some(&encrypted_data.salt), shared_secret.as_bytes());
    shared_secret.zeroize();
    let mut key_bytes = [0u8; KEY_LENGTH_32];
    hk.expand(DERIVATION_KEY, &mut key_bytes).unwrap();

    // decrypt
    let plaintext = symmetric::decrypt(&key_bytes, &encrypted_data.encrypted_data);
    key_bytes.zeroize();

    plaintext
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_asymmetric_roundtrip() {
        let plaintext = b"secure payload";

        let private_key_src = StaticSecret::random();
        let private_key_bytes: [u8; 32] = private_key_src.to_bytes();
        let public_key = PublicKey::from(&private_key_src);

        let encrypted = encrypt(public_key.as_bytes(), plaintext);

        let decrypted = decrypt(&private_key_bytes, &encrypted).unwrap();
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_asymmetric_wrong_private_key() {
        let plaintext = b"secure payload";

        let private_key_src = StaticSecret::random();
        let public_key = PublicKey::from(&private_key_src);

        let encrypted = encrypt(public_key.as_bytes(), plaintext);

        // Try decrypting with a WRONG private key
        let wrong_private_key = StaticSecret::random();
        let wrong_private_key_bytes: [u8; 32] = wrong_private_key.to_bytes();

        let result = decrypt(&wrong_private_key_bytes, &encrypted);
        assert!(result.is_none());
    }

    #[test]
    fn test_asymmetric_randomness() {
        let plaintext = b"secure payload";

        let private_key_src = StaticSecret::random();
        let public_key = PublicKey::from(&private_key_src);

        let encrypted1 = encrypt(public_key.as_bytes(), plaintext);
        let encrypted2 = encrypt(public_key.as_bytes(), plaintext);

        // It should use different ephemeral keys and nonces/salts each time.
        assert_ne!(encrypted1.salt, encrypted2.salt);
        assert_ne!(encrypted1.public_key, encrypted2.public_key);
    }
}
