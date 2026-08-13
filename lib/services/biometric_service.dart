import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_theme.dart';
import '../utils/ios_helpers.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyEmail = 'biometric_user_email';
  static const String _keyPassword = 'biometric_user_password';
  static const String _keyEnabled = 'biometric_enabled';

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

  /// حفظ بيانات الاعتماد آمنًا عند تفعيل البصمة
  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyEnabled, value: 'true');
  }

  /// قراءة بيانات الاعتماد المحفوظة للبصمة
  static Future<Map<String, String>?> getSavedCredentials() async {
    final enabled = await _storage.read(key: _keyEnabled);
    if (enabled != 'true') return null;

    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);

    if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// هل تم تسجيل وتفعيل البصمة مسبقاً؟
  static Future<bool> hasSavedCredentials() async {
    final creds = await getSavedCredentials();
    return creds != null;
  }

  /// مسح بيانات البصمة المحفوظة عند رغبة المستخدم في إلغاء التفعيل
  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyEnabled);
  }

  /// عرض BottomSheet للمستخدم لسؤاله عن تفعيل البصمة بعد تسجيل الدخول أو إنشاء الحساب
  static Future<bool> promptEnableBiometric(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    final bool available = await isBiometricAvailable();
    if (!available) return false;

    final bool alreadyEnabled = await hasSavedCredentials();
    if (alreadyEnabled) {
      // تحديث البيانات المحفوظة تلقائياً
      await saveCredentials(email: email, password: password);
      return true;
    }

    if (!context.mounted) return false;

    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.cardBorder, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.primaryGlow,
                ),
                child: Icon(
                  getBiometricIcon(),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تفعيل الدخول بالبصمة 🛡️',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هل ترغب بتفعيل البصمة لتسجيل الدخول السريع في المرات القادمة بدون الحاجة لكتابة كلمة المرور؟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'ليس الآن',
                        style: GoogleFonts.cairo(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.primaryGlow,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final authSuccess = await authenticate(
                            localizedReason: 'إثبات الهوية لتفعيل البصمة للحساب',
                          );
                          if (authSuccess) {
                            await saveCredentials(email: email, password: password);
                            if (ctx.mounted) Navigator.pop(ctx, true);
                          } else {
                            if (ctx.mounted) Navigator.pop(ctx, false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'تفعيل الآن',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }
}

