import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// التثبت من إمكانية استخدام المصادقة الحيوية (البصمة / الوجه)
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// إرجاع قائمة الأنواع المتاحة (بصمة إصبع، بصمة وجه)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// طلب مصادقة البصمة أو الوجه من المستخدم
  static Future<bool> authenticate({
    String localizedReason = 'يرجى إثبات هويتك بواسطة البصمة أو الوجه لدخول التطبيق',
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
