import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/reel_model.dart';
import 'reel_audio_sheet.dart';

class ReelCaptionWidget extends StatefulWidget {
  final ReelModel reel;
  final VoidCallback onFollowTap;

  const ReelCaptionWidget({
    super.key,
    required this.reel,
    required this.onFollowTap,
  });

  @override
  State<ReelCaptionWidget> createState() => _ReelCaptionWidgetState();
}

class _ReelCaptionWidgetState extends State<ReelCaptionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;

    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 70, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // User Avatar & Name & Follow Button Row
          Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFE11D74), Color(0xFFF43F5E)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(reel.userAvatar),
                ),
              ),
              const SizedBox(width: 10),

              // Username & Display Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            reel.userDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (reel.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF1B73E8),
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '@${reel.username}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Follow Button with Animation
              GestureDetector(
                onTap: widget.onFollowTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: reel.isFollowing
                        ? Colors.white.withValues(alpha: 0.15)
                        : const Color(0xFFE11D74),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: reel.isFollowing
                          ? Colors.white.withValues(alpha: 0.3)
                          : const Color(0xFFE11D74),
                    ),
                  ),
                  child: Text(
                    reel.isFollowing ? 'متابع' : 'متابعة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Caption Text (Expandable)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: _isExpanded ? 10 : 2,
                  overflow: _isExpanded ? TextOverflow.clip : TextOverflow.ellipsis,
                  text: TextSpan(
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    children: _buildCaptionSpans(reel.caption, reel.hashtags),
                  ),
                ),
                if (reel.caption.length > 60)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _isExpanded ? 'أقل' : 'المزيد',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Audio Title Bar (Clickable)
          if (reel.audioName != null)
            GestureDetector(
              onTap: () {
                ReelAudioSheet.show(
                  context,
                  audioName: reel.audioName!,
                  audioAuthor: reel.audioAuthor ?? reel.userDisplayName,
                  audioCoverUrl: reel.audioCoverUrl ?? reel.userAvatar,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      color: Color(0xFFE11D74),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        reel.audioName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  List<InlineSpan> _buildCaptionSpans(String caption, List<String> hashtags) {
    final spans = <InlineSpan>[];
    final words = caption.split(' ');

    for (final word in words) {
      if (word.startsWith('#') || word.startsWith('@')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: GoogleFonts.cairo(
              color: const Color(0xFFE11D74),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: '$word '));
      }
    }

    return spans;
  }
}
