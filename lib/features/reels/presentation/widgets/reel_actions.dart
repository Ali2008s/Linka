import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/reel_model.dart';
import 'reel_comments_sheet.dart';
import 'reel_audio_sheet.dart';

class ReelActionsWidget extends StatefulWidget {
  final ReelModel reel;
  final VoidCallback onLikeTap;
  final VoidCallback onSaveTap;

  const ReelActionsWidget({
    super.key,
    required this.reel,
    required this.onLikeTap,
    required this.onSaveTap,
  });

  @override
  State<ReelActionsWidget> createState() => _ReelActionsWidgetState();
}

class _ReelActionsWidgetState extends State<ReelActionsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _discController;

  @override
  void initState() {
    super.initState();
    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _discController.dispose();
    super.dispose();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _handleShare(BuildContext context) {
    final text = 'شاهد هذا الريل الرائع على تطبيقي: ${widget.reel.caption}\n${widget.reel.videoUrl}';
    // ignore: deprecated_member_use
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like Button
        _buildActionButton(
          icon: reel.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          iconColor: reel.isLiked ? const Color(0xFFE11D74) : Colors.white,
          label: _formatCount(reel.likesCount),
          onTap: widget.onLikeTap,
        ),

        const SizedBox(height: 18),

        // Comments Button
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: Colors.white,
          label: _formatCount(reel.commentsCount),
          onTap: () {
            ReelCommentsSheet.show(
              context,
              reelId: reel.id,
              initialCount: reel.commentsCount,
            );
          },
        ),

        const SizedBox(height: 18),

        // Repost Button
        _buildActionButton(
          icon: Icons.repeat_rounded,
          iconColor: Colors.white,
          label: _formatCount(reel.sharesCount),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تمت إعادة نشر الفيديو بنجاح!',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: const Color(0xFFE11D74),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        // Save / Bookmark Button
        _buildActionButton(
          icon: reel.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          iconColor: reel.isSaved ? const Color(0xFFE11D74) : Colors.white,
          label: 'حفظ',
          onTap: () {
            widget.onSaveTap();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  reel.isSaved ? 'تمت إضافة الفيديو إلى المحفوظات' : 'تمت إزالة الفيديو من المحفوظات',
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: const Color(0xFF17171C),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        // Share Button
        _buildActionButton(
          icon: Icons.share_rounded,
          iconColor: Colors.white,
          label: 'مشاركة',
          onTap: () => _handleShare(context),
        ),

        const SizedBox(height: 24),

        // Rotating Audio Vinyl Disc
        GestureDetector(
          onTap: () {
            if (reel.audioName != null) {
              ReelAudioSheet.show(
                context,
                audioName: reel.audioName!,
                audioAuthor: reel.audioAuthor ?? reel.userDisplayName,
                audioCoverUrl: reel.audioCoverUrl ?? reel.userAvatar,
              );
            }
          },
          child: RotationTransition(
            turns: _discController,
            child: Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2B2B36), Color(0xFF141418)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(reel.audioCoverUrl ?? reel.userAvatar),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
