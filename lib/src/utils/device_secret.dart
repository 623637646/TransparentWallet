import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:transparent_wallet/src/utils/logger.dart';

class DeviceSecretManager {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
      accessControlFlags: [],
      synchronizable: false,
    ),

    aOptions: AndroidOptions(
      resetOnError: true,
      migrateOnAlgorithmChange: true,
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      enforceBiometrics: false,
    ),
  );

  static const String _keyName = "hardware_based_device_secret";

  static Future<String> getDeviceSecret() async {
    String? secret = await _storage.read(key: _keyName);

    if (secret == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      secret = base64Url.encode(values);
      logger.d("Generated device secret: $secret");
      await _storage.write(key: _keyName, value: secret);
    }

    return secret;
  }

  static Future<List<int>> getDeviceSecretBytes() async {
    final secret = await getDeviceSecret();
    return base64Url.decode(secret);
  }
}
