import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class ReelPlayerWidget extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isInitialized;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  const ReelPlayerWidget({
    super.key,
    required this.controller,
    required this.isInitialized,
    required this.onTap,
    required this.onRetry,
  });

  @override
  State<ReelPlayerWidget> createState() => _ReelPlayerWidgetState();
}

class _ReelPlayerWidgetState extends State<ReelPlayerWidget> {
  bool _showPlayIcon = false;

  void _handleTap() {
    widget.onTap();
    if (widget.controller != null && widget.controller!.value.isInitialized) {
      if (!widget.controller!.value.isPlaying) {
        setState(() => _showPlayIcon = true);
      } else {
        setState(() => _showPlayIcon = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // Error State
    if (controller != null && controller.value.hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE11D74),
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                'فشل تحميل الفيديو',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D74),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Video Loaded State
    if (controller != null && widget.isInitialized && controller.value.isInitialized) {
      final size = controller.value.size;
      final isPaused = !controller.value.isPlaying;

      return GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full Screen Vertical BoxFit.cover
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: size.width > 0 ? size.width : MediaQuery.of(context).size.width,
                height: size.height > 0 ? size.height : MediaQuery.of(context).size.height,
                child: VideoPlayer(controller),
              ),
            ),

            // Buffering Indicator
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.isBuffering) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE11D74),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Animated Center Play Icon Overlay when Paused
            if (isPaused || _showPlayIcon)
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isPaused ? 0.9 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),

            // Bottom Progress Bar Indicator
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFFE11D74),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Loading / Buffer Spinner Placeholder
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE11D74),
        ),
      ),
    );
  }
}
