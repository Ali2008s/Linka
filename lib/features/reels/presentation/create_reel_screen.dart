import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../services/telegram_upload_service.dart';
import '../controllers/reels_controller.dart';
import '../models/reel_model.dart';

class CreateReelScreen extends StatefulWidget {
  final ReelsController controller;

  const CreateReelScreen({
    super.key,
    required this.controller,
  });

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _audioController = TextEditingController(text: 'الصوت الأصلي - أنت 🎵');
  
  XFile? _pickedVideo;
  VideoPlayerController? _playerController;
  bool _isInitializing = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final List<String> _suggestedHashtags = ['#فيديو', '#جديد', '#تصوير', '#إبداع', '#ريلز', '#فن'];

  @override
  void initState() {
    super.initState();
    _pickVideoFromGallery();
  }

  Future<void> _pickVideoFromGallery() async {
    setState(() => _isInitializing = true);
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        await _initPreviewController(video);
      }
    } catch (e) {
      // User cancelled or error
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _initPreviewController(XFile video) async {
    _playerController?.dispose();
    final controller = VideoPlayerController.file(File(video.path));
    await controller.initialize();
    controller.setLooping(true);
    controller.play();

    if (mounted) {
      setState(() {
        _pickedVideo = video;
        _playerController = controller;
      });
    }
  }

  void _addHashtag(String tag) {
    final currentText = _captionController.text;
    if (!currentText.contains(tag)) {
      _captionController.text = currentText.isEmpty ? tag : '$currentText $tag';
      _captionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _captionController.text.length),
      );
    }
  }

  Future<void> _publishReel() async {
    if (_pickedVideo == null || _isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.1;
    });

    // Smooth upload progress ticker while transmitting to Telegram Cloud API
    final progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_uploadProgress < 0.85) {
          _uploadProgress += 0.08;
        }
      });
    });

    // Real video upload to Telegram Cloud Storage
    final File videoFile = File(_pickedVideo!.path);
    final String? telegramVideoUrl = await TelegramUploadService.uploadVideo(videoFile);

    progressTimer.cancel();

    if (!mounted) return;

    setState(() {
      _uploadProgress = 1.0;
    });

    // Extract hashtags and details
    final captionText = _captionController.text.trim();
    final extractedHashtags = _suggestedHashtags.where((h) => captionText.contains(h)).toList();

    // Use direct Telegram URL if successful, or fallback to local path
    final finalVideoUrl = telegramVideoUrl ?? _pickedVideo!.path;

    final newReel = ReelModel(
      id: 'reel_user_${DateTime.now().millisecondsSinceEpoch}',
      videoUrl: finalVideoUrl,
      thumbnailUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
      userId: 'current_user',
      username: 'أنت',
      userDisplayName: 'حسابي الشخصي',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      verified: true,
      caption: captionText.isEmpty ? 'ريل جديد ✨' : captionText,
      hashtags: extractedHashtags.isEmpty ? ['#ريلز', '#جديد'] : extractedHashtags,
      likesCount: 1,
      commentsCount: 0,
      sharesCount: 0,
      viewsCount: 1,
      audioId: 'audio_user',
      audioName: _audioController.text.trim(),
      audioAuthor: 'حسابي الشخصي',
      audioCoverUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      createdAt: DateTime.now(),
      isLiked: true,
      isSaved: false,
      isFollowing: true,
    );

    // Insert into reels feed & focus at top position 0
    widget.controller.addNewReel(newReel);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_done_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                telegramVideoUrl != null
                    ? 'تم رفع الريل بنجاح على سيرفرات تليجرام السحابية! 🚀☁️'
                    : 'تم نشر الريل بنجاح وحفظه في الصفحة! 🎉',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE11D74),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _playerController?.dispose();
    _captionController.dispose();
    _audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Preview or Picker Placeholder
          if (_pickedVideo != null && _playerController != null && _playerController!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _playerController!.value.size.width,
                height: _playerController!.value.size.height,
                child: VideoPlayer(_playerController!),
              ),
            )
          else
            _buildEmptyPickerPlaceholder(),

          // 2. Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'نشر ريل جديد',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_pickedVideo != null)
                      IconButton(
                        icon: const Icon(Icons.video_library_rounded, color: Colors.white),
                        onPressed: _pickVideoFromGallery,
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // 3. Telegram-Style Bottom Editor Sheet
          if (_pickedVideo != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildTelegramStyleBottomBar(),
            ),

          // 4. Upload Progress Overlay (Telegram Style Progress)
          if (_isUploading)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: _uploadProgress,
                            strokeWidth: 6,
                            color: const Color(0xFFE11D74),
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        Text(
                          '${(_uploadProgress * 100).toInt()}%',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'جاري معالجة ورفع الريل...',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPickerPlaceholder() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE11D74),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Icon(
              Icons.video_camera_back_rounded,
              color: Color(0xFFE11D74),
              size: 50,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'اختر فيديو لنشره في الريلز',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم باختيار فيديو عمودي من المعرض لمشاركته مع الجميع',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickVideoFromGallery,
            icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
            label: Text(
              'اختر من المعرض',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D74),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelegramStyleBottomBar() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF141418).withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Suggested Hashtags Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _suggestedHashtags.map((tag) {
                    return GestureDetector(
                      onTap: () => _addHashtag(tag),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: const Color(0xFFE11D74),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),

              // Audio Title Field
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note_rounded, color: Color(0xFFE11D74), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _audioController,
                        style: GoogleFonts.cairo(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'اسم الصوت المصاحب...',
                          hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Caption Input Field & Telegram Floating Send Button Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: TextField(
                        controller: _captionController,
                        maxLines: 3,
                        minLines: 1,
                        style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'أضف وصفاً مميزاً للريل الخاص بك...',
                          hintStyle: GoogleFonts.cairo(color: Colors.white38, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Telegram Floating Send Button
                  GestureDetector(
                    onTap: _publishReel,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE11D74), Color(0xFFF43F5E)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D74).withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
