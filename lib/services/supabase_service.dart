import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  // Auth State
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // Email Sign Up (sends OTP)
  static Future<void> signUpWithEmail(String email) async {
    await _client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  // OTP Verification
  static Future<AuthResponse> verifyEmailOtp(String email, String token) async {
    return await _client.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: token,
    );
  }

  // Update Password
  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // Send Password Reset OTP
  static Future resetPasswordForEmail(String email) async {
    await _client.auth.signInWithOtp(email: email, shouldCreateUser: false);
  }

  // Verify Reset Password OTP
  static Future<AuthResponse> verifyResetOtp(String email, String token) async {
    return await _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: token,
    );
  }

  // Sign In with Email + Password
  static Future<AuthResponse> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign In
  static Future<AuthResponse?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      // Web Client ID من Google Cloud Console
      serverClientId:
          '470133182859-cqf7aesb8gj5vcsi00e9lkjdmbb6hige.apps.googleusercontent.com',
    );

    // تسجيل خروج أي جلسة سابقة لتجنب التعارض
    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null; // المستخدم ألغى العملية

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception(
        'لم يتم الحصول على ID Token. تأكد من صحة serverClientId والـ SHA-1.',
      );
    }

    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // Upload Avatar
  static Future<String?> uploadAvatar(File imageFile) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final filePath = 'avatars/$userId.jpg';
    await _client.storage
        .from('avatars')
        .upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('avatars').getPublicUrl(filePath);
  }

  // Check if email already exists in Supabase Auth
  // signInWithOtp with shouldCreateUser:false behaviour:
  //   - User EXISTS     → OTP sent, no exception → return true (block signup)
  //   - User NOT FOUND  → throws exception        → return false (allow signup)
  static Future<bool> doesEmailExist(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email.trim().toLowerCase(),
        shouldCreateUser: false,
      );
      // No exception → user exists
      return true;
    } catch (_) {
      // Any error (user not found, etc.) → user doesn't exist
      return false;
    }
  }

  // Upsert Profile
  static Future<void> upsertProfile({
    required String fullName,
    required String username,
    String? avatarUrl,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    await _client.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Get Profile
  static Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    return await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  // Check username availability
  static Future<bool> isUsernameAvailable(String username) async {
    final result = await _client
        .from('profiles')
        .select('id')
        .eq('username', username)
        .maybeSingle();
    return result == null;
  }

  // Sign Out
  static Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _client.auth.signOut();
  }
}
