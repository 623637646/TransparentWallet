use crate::nonce::generate_nonce;
use aes_gcm::{
    Aes256Gcm, Key, Nonce,
    aead::{Aead, KeyInit},
};
use rkyv::{Archive, Deserialize, Serialize};

pub(crate) const SYMMETRIC_NONCE_LENGTH: usize = 12;

#[derive(Archive, Deserialize, Serialize, Debug, PartialEq, Clone)]
#[rkyv(compare(PartialEq), derive(Debug))]
pub(crate) struct EncryptedData {
    nonce: [u8; SYMMETRIC_NONCE_LENGTH],
    ciphertext: Vec<u8>,
}

pub(crate) fn encrypt(data_key: &[u8], plaintext: &[u8]) -> EncryptedData {
    let key = Key::<Aes256Gcm>::from_slice(data_key);
    let cipher = Aes256Gcm::new(key);
    let nonce_bytes = generate_nonce();
    let nonce = Nonce::from_slice(&nonce_bytes);
    let ciphertext = cipher.encrypt(nonce, plaintext).unwrap();
    EncryptedData {
        nonce: nonce_bytes,
        ciphertext,
    }
}

pub(crate) fn decrypt(data_key: &[u8], encrypted_data: &EncryptedData) -> Option<Vec<u8>> {
    let key = Key::<Aes256Gcm>::from_slice(data_key);
    let cipher = Aes256Gcm::new(key);
    let nonce = Nonce::from_slice(&encrypted_data.nonce);
    cipher
        .decrypt(nonce, encrypted_data.ciphertext.as_slice())
        .ok()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_symmetric_encrypt_decrypt() {
        let key = [42u8; 32];
        let plaintext = b"hello secret world";

        let encrypted = encrypt(&key, plaintext);
        assert_ne!(encrypted.ciphertext, plaintext); // Basic check it's encrypted

        let decrypted = decrypt(&key, &encrypted).unwrap();
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_symmetric_decrypt_wrong_key() {
        let key = [42u8; 32];
        let wrong_key = [43u8; 32];
        let plaintext = b"hello secret world";

        let encrypted = encrypt(&key, plaintext);

        let result = decrypt(&wrong_key, &encrypted);
        assert!(result.is_none());
    }

    #[test]
    fn test_symmetric_tampered_ciphertext() {
        let key = [42u8; 32];
        let plaintext = b"hello secret world";

        let mut encrypted = encrypt(&key, plaintext);

        // Tamper with the ciphertext
        if let Some(last_byte) = encrypted.ciphertext.last_mut() {
            *last_byte ^= 1;
        }

        let result = decrypt(&key, &encrypted);
        assert!(result.is_none()); // Auth tag validation should fail
    }

    #[test]
    fn test_symmetric_different_nonces() {
        let key = [42u8; 32];
        let plaintext = b"hello secret world";

        let encrypted1 = encrypt(&key, plaintext);
        let encrypted2 = encrypt(&key, plaintext);

        assert_ne!(encrypted1.nonce, encrypted2.nonce);
        assert_ne!(encrypted1.ciphertext, encrypted2.ciphertext);
    }
}
