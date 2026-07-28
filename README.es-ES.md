# Janus Wallet — Un Monedero de Criptomonedas Seguro de Modo Dual

> Nombrado en honor a **Janus**, el dios romano de la dualidad: una cara guarda las llaves en silencio, la otra habla con el mundo.

**Janus Wallet** es una aplicación de monedero de criptomonedas diseñada con una **arquitectura de modo dual**:
**Modo Cold Wallet** (Monedero Frío) y **Modo Hot Wallet** (Monedero Caliente).
En cualquier momento dado, una instancia del programa solo puede operar en un modo.

---

## 🧊 Modo Cold Wallet

El **Cold Wallet** se enfoca en la **gestión segura de llaves y la firma de transacciones**.
Es responsable de proteger la información sensible como **frases mnemónicas, frases semilla y llaves privadas**.
Para garantizar la máxima seguridad, el cold wallet opera **completamente offline**:

- Sin conexión a internet
- Wi-Fi, Bluetooth y todas las interfaces de comunicación externa están desactivadas
- El dispositivo se utiliza exclusivamente para operaciones criptográficas

En este modo, el cold wallet realiza las siguientes funciones clave:

- **Generar nuevas direcciones de monedero** y **llaves públicas extendidas (xpub)** para la gestión de activos
- **Firmar transacciones offline** utilizando las llaves privadas almacenadas
- **Mostrar códigos QR** que contienen información pública (por ejemplo, direcciones, transacciones firmadas) para que el hot wallet los escanee

Esto asegura que las llaves privadas **nunca salgan del dispositivo cold wallet** bajo ninguna circunstancia.

---

## 🔥 Modo Hot Wallet

El **Hot Wallet** es responsable de las **operaciones de red** y la **interacción del usuario con la blockchain**.
Se conecta a internet para recuperar datos de la blockchain e interactuar con servicios descentralizados.
Sus responsabilidades principales incluyen:

- **Obtener saldos de activos en tiempo real** e historial de transacciones
- **Construir transacciones no firmadas** basadas en las acciones del usuario
- **Mostrar transacciones no firmadas como códigos QR** para que el cold wallet los escanee
- **Escanear transacciones firmadas** del cold wallet y **transmitirlas (broadcast) a la blockchain**

En este modo, las llaves privadas **nunca quedan expuestas**; toda la firma ocurre exclusivamente en el cold wallet.

---

## 🔄 Interacción entre Cold & Hot Wallet

Los usuarios pueden ejecutar dos instancias de Janus Wallet simultáneamente: una en **Modo Cold** y otra en **Modo Hot**.
Ambos monederos **se comunican enteramente a través de códigos QR**, creando un **flujo de trabajo totalmente air-gapped y verificable**.

El flujo del proceso es el siguiente:

1. **Intercambio de Direcciones**
   - El cold wallet genera direcciones de monedero o una llave pública extendida (xpub)
   - Muestra esta información como un código QR
   - El hot wallet escanea el código QR para importar la dirección o xpub, permitiéndole ver saldos e historial de transacciones

2. **Creación de Transacciones**
   - El hot wallet prepara una transacción no firmada y la muestra como un código QR
   - El cold wallet escanea este código, verifica los detalles de la transacción y la firma de forma segura y offline

3. **Transmisión de Transacciones**
   - El cold wallet muestra la transacción firmada como un nuevo código QR
   - El hot wallet escanea este código y transmite la transacción a la red de la blockchain

Este modelo de **comunicación offline basada en QR** garantiza que todas las operaciones criptográficas sean **transparentes, seguras y auditables**.
Combina la **conveniencia de un hot wallet** con la **seguridad de un cold wallet**: dos caras de la misma moneda, al igual que los dos rostros de **Janus**.

---

## 📱 Plataformas Soportadas

- Android
- iOS

---

## 🚀 Primeros Pasos

### Prerrequisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (≥ 3.12)
- [Rust toolchain](https://rustup.rs/) (stable)
- Herramientas de construcción específicas de la plataforma (Xcode para iOS/macOS, Android SDK, etc.)

### Construcción y Ejecución

```bash
# Instalar dependencias de Flutter
flutter pub get

# Generar código del puente (bridge)
flutter_rust_bridge_codegen generate

# Ejecutar la aplicación en modo debug
flutter run
```

---

## 📄 Licencia

Este proyecto está licenciado bajo la [MIT License](LICENSE).
