import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/supabase_service.dart';
import '../services/telegram_upload_service.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _usernameAvailable = true;
  bool _checkingUsername = false;
  String? _usernameError;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 512,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _checkUsername(String username) async {
    if (username.length < 3) {
      setState(() {
        _usernameError = 'اسم المستخدم يجب 3 أحرف على الأقل';
        _usernameAvailable = false;
      });
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      setState(() {
        _usernameError = 'أحرف إنجليزية وأرقام وشرطة سفلية فقط';
        _usernameAvailable = false;
      });
      return;
    }
    setState(() => _checkingUsername = true);
    final available = await SupabaseService.isUsernameAvailable(username);
    setState(() {
      _checkingUsername = false;
      _usernameAvailable = available;
      _usernameError = available ? null : 'اسم المستخدم مستخدم من قبل شخص آخر';
    });
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _usernameController.text.trim().length >= 3 &&
      _usernameAvailable &&
      !_checkingUsername;

  void _handleCreateAccount() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    try {
      String? avatarUrl;
      if (_selectedImage != null) {
        // الرفع عبر تليجرام للحصول على تخزين غير محدود
        avatarUrl = await TelegramUploadService.uploadImage(_selectedImage!);
        // fallback لـ Supabase إذا لم يتم ضبط Bot Token أو حدث فشل
        avatarUrl ??= await SupabaseService.uploadAvatar(_selectedImage!);
      }
      await SupabaseService.upsertProfile(
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
        avatarUrl: avatarUrl,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'خطأ: ${e.toString()}',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.primaryGlow,
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'أكمل ملفك الشخصي',
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'أضف صورة ومعلوماتك لإكمال إنشاء الحساب',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Avatar Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _selectedImage == null
                                ? AppColors.primaryGradient
                                : null,
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            border: Border.all(
                              color: AppColors.primaryOrange.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: _selectedImage == null
                              ? const Icon(Icons.person_rounded,
                                  color: Colors.white, size: 48)
                              : null,
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.background, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'اضغط لإضافة صورة',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Full Name
                Text(
                  'الاسم الكامل',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'مثال: علي محمد',
                  autoFocus: true,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                // Username
                Row(
                  children: [
                    Text(
                      'اسم المستخدم',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_checkingUsername)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else if (_usernameController.text.isNotEmpty && _usernameAvailable)
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'متاح',
                            style: GoogleFonts.cairo(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _usernameController,
                  hintText: '@username',
                  onChanged: (val) {
                    setState(() {});
                    if (val.length >= 3) {
                      _checkUsername(val.trim());
                    } else {
                      setState(() {
                        _usernameError = val.isEmpty ? null : 'اسم المستخدم يجب 3 أحرف على الأقل';
                        _usernameAvailable = false;
                      });
                    }
                  },
                ),
                if (_usernameError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _usernameError!,
                    style: GoogleFonts.cairo(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                CustomButton(
                  text: 'إنشاء الحساب والدخول',
                  type: CustomButtonType.primary,
                  isLoading: _isLoading,
                  onPressed: _isValid ? _handleCreateAccount : null,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
