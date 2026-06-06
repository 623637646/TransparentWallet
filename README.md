# Janus Wallet — A Secure Dual-Mode Cryptocurrency Wallet

> Named after **Janus**, the Roman god of duality — one face guards the keys in silence, the other speaks to the world.

**Janus Wallet** is a cryptocurrency wallet application designed with a **dual-mode architecture**:
**Cold Wallet Mode** and **Hot Wallet Mode**.
At any given time, one instance of the program can only operate in one mode.

---

## 🧊 Cold Wallet Mode

The **Cold Wallet** focuses on **secure key management and transaction signing**.
It is responsible for protecting sensitive information such as **mnemonic phrases, seed phrases, and private keys**.
To ensure maximum security, the cold wallet operates **completely offline**:

- No internet connection
- Wi-Fi, Bluetooth, and all external communication interfaces are disabled
- The device is used exclusively for cryptographic operations

In this mode, the cold wallet performs the following key functions:

- **Generate new wallet addresses** and **extended public keys (xpub)** for asset management
- **Sign transactions offline** using stored private keys
- **Display QR codes** containing public information (e.g., addresses, signed transactions) for the hot wallet to scan

This ensures that private keys **never leave the cold wallet device** under any circumstances.

---

## 🔥 Hot Wallet Mode

The **Hot Wallet** is responsible for **networked operations** and **user interaction with the blockchain**.
It connects to the internet to retrieve blockchain data and interact with decentralized services.
Its primary responsibilities include:

- **Fetching real-time asset balances** and transaction history
- **Constructing unsigned transactions** based on user actions
- **Displaying unsigned transactions as QR codes** for the cold wallet to scan
- **Scanning signed transactions** from the cold wallet and **broadcasting them to the blockchain**

In this mode, private keys are **never exposed** — all signing occurs exclusively in the cold wallet.

---

## 🔄 Cold & Hot Wallet Interaction

Users can run two instances of Janus Wallet simultaneously — one in **Cold Mode** and one in **Hot Mode**.
The two wallets **communicate entirely via QR codes**, creating a **fully air-gapped and verifiable workflow**.

The process flow is as follows:

1. **Address Exchange**
   - The cold wallet generates wallet addresses or an extended public key (xpub)
   - It displays this information as a QR code
   - The hot wallet scans the QR code to import the address or xpub, enabling it to view balances and transaction history

2. **Transaction Creation**
   - The hot wallet prepares an unsigned transaction and displays it as a QR code
   - The cold wallet scans this code, verifies the transaction details, and signs it securely offline

3. **Transaction Broadcast**
   - The cold wallet displays the signed transaction as a new QR code
   - The hot wallet scans this code and broadcasts the transaction to the blockchain network

This **QR-based offline communication** model ensures that all cryptographic operations are **transparent, secure, and auditable**.
It combines the **convenience of a hot wallet** with the **security of a cold wallet** — two sides of the same coin, just like the two faces of **Janus**.

---

## 📱 Supported Platforms

- Android
- iOS

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (≥ 3.12)
- [Rust toolchain](https://rustup.rs/) (stable)
- Platform-specific build tools (Xcode for iOS/macOS, Android SDK, etc.)

### Build & Run

```bash
# Install Flutter dependencies
flutter pub get

# Generate bridge code
flutter_rust_bridge_codegen generate

# Run the app in debug mode
flutter run
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
