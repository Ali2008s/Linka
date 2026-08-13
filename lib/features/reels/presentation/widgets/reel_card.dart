import 'package:flutter/material.dart';
import '../../controllers/reels_controller.dart';
import '../../models/reel_model.dart';
import 'double_tap_heart_overlay.dart';
import 'reel_actions.dart';
import 'reel_caption.dart';
import 'reel_player.dart';

class ReelCardWidget extends StatelessWidget {
  final ReelModel reel;
  final int index;
  final ReelsController controller;

  const ReelCardWidget({
    super.key,
    required this.reel,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final videoController = controller.controllers[index];
    final isInitialized = controller.initializedMap[index] ?? false;

    return DoubleTapHeartOverlay(
      onDoubleTap: () {
        if (!reel.isLiked) {
          controller.toggleLike(index);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Player
          ReelPlayerWidget(
            controller: videoController,
            isInitialized: isInitialized,
            onTap: () => controller.togglePlayPause(index),
            onRetry: () => controller.retryVideo(index),
          ),

          // 2. Subtle Dark Gradient Overlay (Bottom to Top)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black54,
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),

          // 3. Audio Mute Indicator Button (Top Corner)
          Positioned(
            left: 16,
            top: 70,
            child: GestureDetector(
              onTap: controller.toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  controller.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // 4. Side Action Column (RTL Positioned on Left side)
          Positioned(
            left: 16,
            bottom: 30,
            child: ReelActionsWidget(
              reel: reel,
              onLikeTap: () => controller.toggleLike(index),
              onSaveTap: () => controller.toggleSave(index),
            ),
          ),

          // 5. Bottom User Info & Caption Section
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: ReelCaptionWidget(
              reel: reel,
              onFollowTap: () => controller.toggleFollow(index),
            ),
          ),
        ],
      ),
    );
  }
}
