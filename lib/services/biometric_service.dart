import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_theme.dart';
import '../utils/ios_helpers.dart';

/// نموذج حساب محفوظ للبصمة
class SavedBiometricAccount {
  final String email;
  final String password;
  final String displayName;
  final String? avatarUrl;

  const SavedBiometricAccount({
    required this.email,
    required this.password,
    required this.displayName,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
      };

  factory SavedBiometricAccount.fromJson(Map<String, dynamic> json) =>
      SavedBiometricAccount(
        email: json['email'] as String,
        password: json['password'] as String,
        displayName: json['displayName'] as String? ?? json['email'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );

  /// الحرف الأول من الاسم للعرض
  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // مفتاح قائمة الحسابات المتعددة
  static const String _keyAccounts = 'biometric_accounts_v2';

  // ───────────────────────────── Core Auth ──────────────────────────────────

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
    String localizedReason =
        'يرجى إثبات هويتك بواسطة البصمة أو الوجه لدخول التطبيق',
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

  // ─────────────────── Multi-Account Storage ────────────────────────────────

  /// قراءة جميع الحسابات المحفوظة
  static Future<List<SavedBiometricAccount>> getSavedAccounts() async {
    try {
      final raw = await _storage.read(key: _keyAccounts);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedBiometricAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// حفظ حساب أو تحديثه (يُضاف إذا جديد، يُحدَّث إذا موجود)
  static Future<void> saveAccount(SavedBiometricAccount account) async {
    final accounts = await getSavedAccounts();
    // ابحث عن نفس الإيميل وحدّثه إن وُجد
    final idx = accounts.indexWhere((a) => a.email == account.email);
    if (idx >= 0) {
      accounts[idx] = account;
    } else {
      accounts.add(account);
    }
    await _storage.write(key: _keyAccounts, value: jsonEncode(accounts.map((a) => a.toJson()).toList()));
  }

  /// حذف حساب واحد بالإيميل
  static Future<void> removeAccount(String email) async {
    final accounts = await getSavedAccounts();
    accounts.removeWhere((a) => a.email == email);
    await _storage.write(key: _keyAccounts, value: jsonEncode(accounts.map((a) => a.toJson()).toList()));
  }

  /// حذف جميع الحسابات المحفوظة
  static Future<void> clearAllAccounts() async {
    await _storage.delete(key: _keyAccounts);
  }

  /// هل يوجد حسابات محفوظة؟
  static Future<bool> hasSavedAccounts() async {
    final accounts = await getSavedAccounts();
    return accounts.isNotEmpty;
  }

  // ─────────────────── Backward compatibility (single creds) ───────────────

  /// للتوافق مع الكود القديم — يُرجع أوّل حساب محفوظ
  static Future<Map<String, String>?> getSavedCredentials() async {
    final accounts = await getSavedAccounts();
    if (accounts.isEmpty) return null;
    return {'email': accounts.first.email, 'password': accounts.first.password};
  }

  static Future<bool> hasSavedCredentials() => hasSavedAccounts();

  static Future<void> clearCredentials() => clearAllAccounts();

  /// حفظ بيانات الاعتماد (للتوافق — يستخدم displayName من الإيميل)
  static Future<void> saveCredentials({
    required String email,
    required String password,
    String? displayName,
    String? avatarUrl,
  }) async {
    await saveAccount(SavedBiometricAccount(
      email: email,
      password: password,
      displayName: displayName ?? email.split('@').first,
      avatarUrl: avatarUrl,
    ));
  }

  // ─────────────────── UI Prompts ───────────────────────────────────────────

  /// عرض BottomSheet لسؤال المستخدم عن تفعيل البصمة بعد تسجيل الدخول
  static Future<bool> promptEnableBiometric(
    BuildContext context, {
    required String email,
    required String password,
    String? displayName,
    String? avatarUrl,
  }) async {
    final bool available = await isBiometricAvailable();
    if (!available) return false;

    // إذا كان هذا الحساب بعينه محفوظاً مسبقاً → حدّثه فقط بصمت
    final accounts = await getSavedAccounts();
    final alreadySaved = accounts.any((a) => a.email == email);
    if (alreadySaved) {
      await saveCredentials(
        email: email,
        password: password,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
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
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.primaryGlow,
                ),
                child: Icon(getBiometricIcon(), color: Colors.white, size: 32),
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
                            await saveCredentials(
                              email: email,
                              password: password,
                              displayName: displayName,
                              avatarUrl: avatarUrl,
                            );
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

  /// عرض قائمة الحسابات لاختيار الحساب (للدخول ببصمة مع متعدد الحسابات)
  /// يُرجع الحساب المختار أو null إذا ألغى المستخدم
  static Future<SavedBiometricAccount?> showAccountPicker(
    BuildContext context,
    List<SavedBiometricAccount> accounts,
  ) async {
    return await showModalBottomSheet<SavedBiometricAccount>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AccountPickerSheet(accounts: accounts),
    );
  }
}

// ─────────────────── Account Picker Widget ────────────────────────────────

class _AccountPickerSheet extends StatefulWidget {
  final List<SavedBiometricAccount> accounts;
  const _AccountPickerSheet({required this.accounts});

  @override
  State<_AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends State<_AccountPickerSheet> {
  late List<SavedBiometricAccount> _accounts;

  @override
  void initState() {
    super.initState();
    _accounts = List.from(widget.accounts);
  }

  Future<void> _deleteAccount(SavedBiometricAccount account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'حذف الحساب من البصمة',
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل تريد إزالة "${account.displayName}" من قائمة البصمة؟',
          style: GoogleFonts.cairo(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BiometricService.removeAccount(account.email);
      setState(() => _accounts.removeWhere((a) => a.email == account.email));
      // إذا فرغت القائمة أغلق الشيت
      if (_accounts.isEmpty && mounted) Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.primaryGlow,
                  ),
                  child: Icon(getBiometricIcon(), color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر الحساب',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'حسابات البصمة المحفوظة على هذا الجهاز',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder, height: 1),

          // Accounts list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _accounts.length,
              separatorBuilder: (_, index) =>
                  const Divider(color: AppColors.cardBorder, height: 1, indent: 72),
              itemBuilder: (_, i) {
                final account = _accounts[i];
                return _AccountTile(
                  account: account,
                  onSelect: () => Navigator.pop(context, account),
                  onDelete: () => _deleteAccount(account),
                );
              },
            ),
          ),

          const Divider(color: AppColors.cardBorder, height: 1),

          // Cancel button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, null),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final SavedBiometricAccount account;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _AccountTile({
    required this.account,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        splashColor: AppColors.primaryOrange.withValues(alpha: 0.08),
        highlightColor: AppColors.primaryOrange.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  image: account.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(account.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: account.avatarUrl == null
                    ? Center(
                        child: Text(
                          account.initials,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),

              // Name + Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.email,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 20),
                onPressed: onDelete,
                tooltip: 'إزالة من البصمة',
                splashRadius: 20,
              ),

              // Arrow
              const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
