import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// مساعد للتمييز بين iOS وAndroid
bool get isIOS => Platform.isIOS;

/// ─── Navigation ──────────────────────────────────────────────────────────────

/// يعطي CupertinoPageRoute على iOS وMaterialPageRoute على Android
PageRoute<T> adaptivePageRoute<T>({required WidgetBuilder builder}) {
  if (isIOS) {
    return CupertinoPageRoute<T>(builder: builder);
  }
  return MaterialPageRoute<T>(builder: builder);
}

/// ─── Progress Indicator ──────────────────────────────────────────────────────

/// يعطي CupertinoActivityIndicator على iOS وCircularProgressIndicator على Android
Widget adaptiveProgressIndicator({
  Color color = Colors.white,
  double size = 22,
  double strokeWidth = 2.5,
}) {
  if (isIOS) {
    return CupertinoActivityIndicator(
      color: color,
      radius: size / 2,
    );
  }
  return SizedBox(
    width: size,
    height: size,
    child: CircularProgressIndicator(
      strokeWidth: strokeWidth,
      valueColor: AlwaysStoppedAnimation<Color>(color),
    ),
  );
}

/// ─── Haptic Feedback ─────────────────────────────────────────────────────────

/// هزة خفيفة - للأزرار العادية
void hapticLight() => HapticFeedback.lightImpact();

/// هزة متوسطة - للأزرار المهمة
void hapticMedium() => HapticFeedback.mediumImpact();

/// هزة تحديد - للـ tab bars
void hapticSelection() => HapticFeedback.selectionClick();

/// هزة خطأ - للـ validation errors
void hapticError() => HapticFeedback.heavyImpact();

/// ─── Keyboard ────────────────────────────────────────────────────────────────

/// إخفاء الكيبورد
void hideKeyboard(BuildContext context) => FocusScope.of(context).unfocus();

/// ─── Status Bar ──────────────────────────────────────────────────────────────

/// ضبط الـ status bar على وضع فاتح (للخلفيات الداكنة)
void setLightStatusBar() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark, // iOS: dark = icons light
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

/// ─── Biometric Icon ──────────────────────────────────────────────────────────

/// يعطي الأيقونة المناسبة للبيومتري حسب النظام
/// على iOS يستخدم Face ID icon، على Android يستخدم fingerprint
IconData getBiometricIcon() {
  if (isIOS) {
    return Icons.face_unlock_rounded;
  }
  return Icons.fingerprint_rounded;
}

/// ─── SnackBar ────────────────────────────────────────────────────────────────

/// يعرض Snack Bar بمظهر مناسب لكلا النظامين
void showAdaptiveSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor:
          isError ? Colors.redAccent : const Color(0xFF17171C),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(
        children: [
          if (isError) ...[
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// ─── Text Scale ──────────────────────────────────────────────────────────────

/// يحدّ من تكبير الخط إلى حد معقول
/// استخدمه لتغليف الشاشات الحساسة للحجم
class BoundedTextScaler extends StatelessWidget {
  final Widget child;
  final double maxScaleFactor;

  const BoundedTextScaler({
    super.key,
    required this.child,
    this.maxScaleFactor = 1.3,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1.0).clamp(
                0.8,
                maxScaleFactor,
              ),
        ),
      ),
      child: child,
    );
  }
}
