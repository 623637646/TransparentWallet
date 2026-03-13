use crate::{
    KEY_LENGTH_16, KEY_LENGTH_32, asymmetric, nonce::generate_nonce, pin_key::derive_pin_key,
    symmetric,
};
use rkyv::{Archive, Deserialize, Serialize};
use x25519_dalek::{PublicKey, StaticSecret};
use zeroize::Zeroize;

#[derive(Archive, Deserialize, Serialize, Debug, PartialEq, Clone)]
#[rkyv(compare(PartialEq), derive(Debug))]
pub struct SecretContext {
    salt: [u8; KEY_LENGTH_16],
    public_key: [u8; KEY_LENGTH_32],
    encrypted_private_key: symmetric::EncryptedData,
}

impl SecretContext {
    pub fn new(pin: &[u8], device_secret: &[u8]) -> Self {
        // generate pin key
        let salt = generate_nonce();
        let mut derived_pin_key = derive_pin_key(pin, device_secret, &salt);

        // generate public and private key
        let mut private_key = StaticSecret::random();
        let public_key = PublicKey::from(&private_key);

        // encrypt private key
        let encrypted_private_key = symmetric::encrypt(&derived_pin_key, private_key.as_bytes());
        derived_pin_key.zeroize();
        private_key.zeroize();

        SecretContext {
            salt,
            public_key: public_key.to_bytes(),
            encrypted_private_key,
        }
    }

    pub fn update_pin(&mut self, old_pin: &[u8], new_pin: &[u8], device_secret: &[u8]) -> bool {
        let mut derived_pin_key = derive_pin_key(old_pin, device_secret, &self.salt);

        // decrypt private key
        let encrypted_private_key =
            symmetric::decrypt(&derived_pin_key, &self.encrypted_private_key);
        derived_pin_key.zeroize();
        match encrypted_private_key {
            Some(mut private_key) => {
                // generate new pin key and salt
                let new_salt = generate_nonce();
                let mut new_derived_pin_key = derive_pin_key(new_pin, device_secret, &new_salt);

                // encrypt private key
                let new_encrypted_private_key =
                    symmetric::encrypt(&new_derived_pin_key, private_key.as_slice());
                new_derived_pin_key.zeroize();
                private_key.zeroize();

                // update
                self.salt = new_salt;
                self.encrypted_private_key = new_encrypted_private_key;

                true
            }
            None => false,
        }
    }

    pub fn verify_pin(&self, pin: &[u8], device_secret: &[u8]) -> bool {
        let mut derived_pin_key = derive_pin_key(pin, device_secret, &self.salt);
        let mut private_key = symmetric::decrypt(&derived_pin_key, &self.encrypted_private_key);
        derived_pin_key.zeroize();
        let result = private_key.is_some();
        private_key.zeroize();
        result
    }

    pub fn to_bytes(&self) -> Vec<u8> {
        let bytes = rkyv::to_bytes::<rkyv::rancor::Error>(self).unwrap();
        bytes.into_vec()
    }

    pub fn from_bytes(bytes: &[u8]) -> Option<Self> {
        rkyv::from_bytes::<Self, rkyv::rancor::Error>(bytes).ok()
    }

    pub fn encrypt(&self, plaintext: &[u8]) -> Vec<u8> {
        let encrypted_data = asymmetric::encrypt(&self.public_key, plaintext);
        let bytes = rkyv::to_bytes::<rkyv::rancor::Error>(&encrypted_data).unwrap();
        bytes.into_vec()
    }

    pub fn decrypt(&self, pin: &[u8], device_secret: &[u8], ciphertext: &[u8]) -> Option<Vec<u8>> {
        let encrypted_data =
            rkyv::from_bytes::<asymmetric::EncryptedData, rkyv::rancor::Error>(ciphertext).ok()?;
        let mut derived_pin_key = derive_pin_key(pin, device_secret, &self.salt);
        let mut private_key = symmetric::decrypt(&derived_pin_key, &self.encrypted_private_key)?;
        derived_pin_key.zeroize();
        let plaintext =
            asymmetric::decrypt(private_key.as_slice().try_into().ok()?, &encrypted_data);
        private_key.zeroize();
        plaintext
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_secret_context_new() {
        let pin = b"123456";
        let device_secret = b"my_device_secret";

        // Generate two contexts, should have different salt/keys due to randomness
        let ctx1 = SecretContext::new(pin, device_secret);
        let ctx2 = SecretContext::new(pin, device_secret);

        assert_ne!(ctx1.salt, ctx2.salt);
        assert_ne!(ctx1.public_key, ctx2.public_key);
        assert_ne!(ctx1.encrypted_private_key, ctx2.encrypted_private_key);
    }

    #[test]
    fn test_secret_context_serialization() {
        let pin = b"123456";
        let device_secret = b"my_device_secret";
        let ctx = SecretContext::new(pin, device_secret);

        let salt = ctx.salt;
        let public_key = ctx.public_key;

        let bytes = ctx.to_bytes();
        let restored_ctx =
            SecretContext::from_bytes(&bytes).expect("Failed to restore SecretContext");

        assert_eq!(salt, restored_ctx.salt);
        assert_eq!(public_key, restored_ctx.public_key);

        let plaintext = b"serialization test";
        let ciphertext = restored_ctx.encrypt(plaintext);
        let decrypted = restored_ctx
            .decrypt(pin, device_secret, &ciphertext)
            .expect("Decryption failed");
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_secret_context_from_bytes_invalid() {
        let invalid_bytes = b"invalid_bytes";
        assert!(SecretContext::from_bytes(invalid_bytes).is_none());
    }

    #[test]
    fn test_secret_context_encrypt_decrypt() {
        let pin = b"123456";
        let device_secret = b"my_device_secret";
        let ctx = SecretContext::new(pin, device_secret);

        let plaintext = b"Hello, transparent wallet!";

        // Encrypt
        let ciphertext = ctx.encrypt(plaintext);

        // Decrypt with correct credentials
        let decrypted = ctx
            .decrypt(pin, device_secret, &ciphertext)
            .expect("Decryption failed");
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_secret_context_decrypt_wrong_pin() {
        let pin = b"123456";
        let device_secret = b"my_device_secret";
        let ctx = SecretContext::new(pin, device_secret);

        let plaintext = b"Hello, World!";
        let ciphertext = ctx.encrypt(plaintext);

        // Decrypt with wrong pin
        let wrong_pin = b"654321";
        assert!(ctx.decrypt(wrong_pin, device_secret, &ciphertext).is_none());
    }

    #[test]
    fn test_secret_context_decrypt_wrong_device_secret() {
        let pin = b"123456";
        let device_secret = b"my_device_secret";
        let ctx = SecretContext::new(pin, device_secret);

        let plaintext = b"Hello, World!";
        let ciphertext = ctx.encrypt(plaintext);

        // Decrypt with wrong device secret
        let wrong_device_secret = b"wrong_device_secret";
        assert!(ctx.decrypt(pin, wrong_device_secret, &ciphertext).is_none());
    }

    #[test]
    fn test_secret_context_decrypt_corrupted_ciphertext() {
        let pin = b"123456";
        let device_secret = b"my_device_secret";
        let ctx = SecretContext::new(pin, device_secret);

        let plaintext = b"Hello, World!";
        let mut ciphertext = ctx.encrypt(plaintext);

        // Corrupt ciphertext
        let last = ciphertext.len() - 1;
        ciphertext[last] ^= 0xff;

        // Decrypt should fail
        assert!(ctx.decrypt(pin, device_secret, &ciphertext).is_none());
    }

    #[test]
    fn test_secret_context_decrypt_invalid_format() {
        let pin = b"123456";
        let device_secret = b"my_device_secret";
        let ctx = SecretContext::new(pin, device_secret);

        let invalid_ciphertext = b"not_a_valid_encrypted_data";

        // Decrypt should fail
        assert!(
            ctx.decrypt(pin, device_secret, invalid_ciphertext)
                .is_none()
        );
    }

    #[test]
    fn test_secret_context_update_pin() {
        let old_pin = b"123456";
        let new_pin = b"654321";
        let device_secret = b"my_device_secret";

        let mut ctx = SecretContext::new(old_pin, device_secret);

        let plaintext = b"Hello, transparent wallet!";
        let ciphertext = ctx.encrypt(plaintext);

        let old_salt = ctx.salt;

        // Update to new pin
        let success = ctx.update_pin(old_pin, new_pin, device_secret);
        assert!(success);

        // Salt should change
        assert_ne!(old_salt, ctx.salt);

        // Old pin should not work
        assert!(ctx.decrypt(old_pin, device_secret, &ciphertext).is_none());

        // New pin should work
        let decrypted = ctx
            .decrypt(new_pin, device_secret, &ciphertext)
            .expect("Decryption failed after update_pin");
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_secret_context_update_pin_wrong_old_pin() {
        let old_pin = b"123456";
        let wrong_old_pin = b"111111";
        let new_pin = b"654321";
        let device_secret = b"my_device_secret";

        let mut ctx = SecretContext::new(old_pin, device_secret);

        // Update to new pin should fail
        let success = ctx.update_pin(wrong_old_pin, new_pin, device_secret);
        assert!(!success);
    }

    #[test]
    fn test_secret_context_verify_pin() {
        let pin = b"123456";
        let device_secret = b"my_device_secret";
        let ctx = SecretContext::new(pin, device_secret);

        // Correct PIN and device secret
        assert!(ctx.verify_pin(pin, device_secret));

        // Wrong PIN
        let wrong_pin = b"654321";
        assert!(!ctx.verify_pin(wrong_pin, device_secret));

        // Wrong device secret
        let wrong_device_secret = b"wrong_secret";
        assert!(!ctx.verify_pin(pin, wrong_device_secret));
    }

    #[test]
    fn test_secret_context_verify_pin_after_update() {
        let old_pin = b"123456";
        let new_pin = b"654321";
        let device_secret = b"my_device_secret";

        let mut ctx = SecretContext::new(old_pin, device_secret);

        assert!(ctx.verify_pin(old_pin, device_secret));

        // Update PIN
        ctx.update_pin(old_pin, new_pin, device_secret);

        // Old PIN should fail
        assert!(!ctx.verify_pin(old_pin, device_secret));

        // New PIN should succeed
        assert!(ctx.verify_pin(new_pin, device_secret));
    }
}
