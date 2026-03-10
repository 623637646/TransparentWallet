use rand::Rng;

pub(crate) fn generate_nonce<const N: usize>() -> [u8; N] {
    let mut key = [0u8; N];
    rand::rng().fill_bytes(&mut key);
    key
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_nonce_length() {
        let nonce: [u8; 12] = generate_nonce();
        assert_eq!(nonce.len(), 12);
        
        let nonce_32: [u8; 32] = generate_nonce();
        assert_eq!(nonce_32.len(), 32);
    }

    #[test]
    fn test_generate_nonce_uniqueness() {
        let nonce1: [u8; 16] = generate_nonce();
        let nonce2: [u8; 16] = generate_nonce();
        assert_ne!(nonce1, nonce2);
    }
}
