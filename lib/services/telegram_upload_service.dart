import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TelegramUploadService {
  static String botToken = '6707537751:AAHs-U9vHvmxDu6iyQSGuec9SWFIeMvbg2A';
  static String rawChatId = '3839994672';

  static String get chatId {
    final id = rawChatId.trim();
    if (id.startsWith('@') || id.startsWith('-')) {
      return id;
    }
    // إذا كان رقمياً فقط لـ Channel، التليجرام يتطلب البادئة -100
    return '-100$id';
  }

  /// رفع صورة إلى قناة التليجرام وإرجاع رابط الصورة المباشر
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$botToken/sendPhoto');

      final request = http.MultipartRequest('POST', url)
        ..fields['chat_id'] = chatId
        ..files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          final photos = data['result']['photo'] as List;
          // أخذ أعلى دقة للصورة (آخر عنصر)
          final largestPhoto = photos.last;
          final String fileId = largestPhoto['file_id'];

          // جلب مسار الملف المباشر من التليجرام
          return await getFileUrl(fileId);
        }
      } else {
        debugPrint('Telegram API Error (${response.statusCode}): ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Telegram Upload Error: $e');
      return null;
    }
  }

  /// رفع فيديو إلى قناة التليجرام وإرجاع الرابط
  static Future<String?> uploadVideo(File videoFile) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$botToken/sendVideo');

      final request = http.MultipartRequest('POST', url)
        ..fields['chat_id'] = chatId
        ..files.add(await http.MultipartFile.fromPath('video', videoFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          final String fileId = data['result']['video']['file_id'];
          return await getFileUrl(fileId);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Telegram Video Upload Error: $e');
      return null;
    }
  }

  /// جلب رابط التنزيل/العرض المباشر للملف من التليجرام
  static Future<String?> getFileUrl(String fileId) async {
    try {
      final url = Uri.parse(
          'https://api.telegram.org/bot$botToken/getFile?file_id=$fileId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          final filePath = data['result']['file_path'];
          return 'https://api.telegram.org/file/bot$botToken/$filePath';
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
