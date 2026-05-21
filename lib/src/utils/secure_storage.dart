import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:janus_wallet/src/utils/logger.dart';

class SecureStorageManager {
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

  FutureOr<String?> Function(String, Uint8List?) writer() {
    return (key, data) async {
      try {
        if (data == null) {
          await _storage.delete(key: key);
        } else {
          await _storage.write(key: key, value: base64Encode(data));
        }
        return null;
      } catch (error, stackTrace) {
        logger.e(
          'Secure storage write failed',
          error: error,
          stackTrace: stackTrace,
        );
        return error.toString();
      }
    };
  }

  FutureOr<(Uint8List?, String?)> Function(String) reader() {
    return (key) async {
      try {
        final value = await _storage.read(key: key);
        if (value == null) return (null, null);
        return (base64Decode(value), null);
      } catch (error, stackTrace) {
        logger.e(
          'Secure storage read failed',
          error: error,
          stackTrace: stackTrace,
        );
        return (null, error.toString());
      }
    };
  }
}
