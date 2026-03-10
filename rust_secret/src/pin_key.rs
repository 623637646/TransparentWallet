use crate::{KEY_LENGTH_16, KEY_LENGTH_32};
use argon2::Argon2;
use zeroize::Zeroize;

pub(crate) fn derive_pin_key(
    pin: &[u8],
    device_secret: &[u8],
    salt: &[u8; KEY_LENGTH_16],
) -> [u8; KEY_LENGTH_32] {
    let mut input = Vec::new();
    input.extend_from_slice(pin);
    input.extend_from_slice(device_secret);

    let mut output = [0u8; KEY_LENGTH_32];

    Argon2::default()
        .hash_password_into(&input, salt, &mut output)
        .unwrap();
    input.zeroize();

    output
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_derive_pin_key_consistency() {
        let pin = b"123456";
        let device_secret = b"my_secret_device_id";
        let salt = [1u8; KEY_LENGTH_16];

        let key1 = derive_pin_key(pin, device_secret, &salt);
        let key2 = derive_pin_key(pin, device_secret, &salt);

        assert_eq!(key1, key2);
    }

    #[test]
    fn test_derive_pin_key_variation() {
        let pin1 = b"123456";
        let pin2 = b"654321";
        let device_secret1 = b"secret1";
        let device_secret2 = b"secret2";
        let salt1 = [1u8; KEY_LENGTH_16];
        let salt2 = [2u8; KEY_LENGTH_16];

        let base_key = derive_pin_key(pin1, device_secret1, &salt1);

        // Change pin
        let diff_pin_key = derive_pin_key(pin2, device_secret1, &salt1);
        assert_ne!(base_key, diff_pin_key);

        // Change device_secret
        let diff_secret_key = derive_pin_key(pin1, device_secret2, &salt1);
        assert_ne!(base_key, diff_secret_key);

        // Change salt
        let diff_salt_key = derive_pin_key(pin1, device_secret1, &salt2);
        assert_ne!(base_key, diff_salt_key);
    }
}
