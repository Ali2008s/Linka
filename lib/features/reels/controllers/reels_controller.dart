import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../data/reels_repository.dart';
import '../models/reel_model.dart';

enum ReelsPageState { loading, success, empty, error }

class ReelsController extends ChangeNotifier with WidgetsBindingObserver {
  final ReelsRepository _repository;

  ReelsPageState state = ReelsPageState.loading;
  List<ReelModel> reels = [];
  int currentIndex = 0;
  int currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  bool isMuted = false;
  String? errorMessage;

  final Map<int, VideoPlayerController> controllers = {};
  final Map<int, bool> initializedMap = {};
  final PageController pageController = PageController();

  ReelsController({ReelsRepository? repository})
      : _repository = repository ?? ReelsRepository() {
    WidgetsBinding.instance.addObserver(this);
    loadInitialReels();
  }

  /// Add newly published reel to index 0 and focus it
  void addNewReel(ReelModel newReel) {
    reels.insert(0, newReel);

    // Dispose old controller maps to re-align indices
    controllers.forEach((_, controller) => controller.dispose());
    controllers.clear();
    initializedMap.clear();

    currentIndex = 0;
    state = ReelsPageState.success;

    _initializeControllerAtIndex(0).then((_) {
      controllers[0]?.play();
      _initializeControllerAtIndex(1);
    });

    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }

    notifyListeners();
  }

  /// Initial fetch of reels
  Future<void> loadInitialReels() async {
    state = ReelsPageState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getReels(page: 1, limit: 10);
      if (result.reels.isEmpty) {
        state = ReelsPageState.empty;
      } else {
        reels = result.reels;
        currentPage = result.page;
        hasMore = result.hasMore;
        state = ReelsPageState.success;
        
        // Initialize current & next video
        _initializeControllerAtIndex(0).then((_) {
          controllers[0]?.play();
          _initializeControllerAtIndex(1);
        });
      }
    } catch (e) {
      state = ReelsPageState.error;
      errorMessage = 'حدث خطأ أثناء تحميل الفيديوهات. يرجى التأكد من الاتصال بالإنترنت.';
    }
    notifyListeners();
  }

  /// Load next page when reaching near end (Pagination)
  Future<void> loadMoreReels() async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final result = await _repository.getReels(page: nextPage, limit: 10);
      if (result.reels.isNotEmpty) {
        reels.addAll(result.reels);
        currentPage = result.page;
        hasMore = result.hasMore;
      } else {
        hasMore = false;
      }
    } catch (_) {
      // Keep existing reels if loadMore fails quietly
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Initialize video player controller for specific reel index
  Future<void> _initializeControllerAtIndex(int index) async {
    if (index < 0 || index >= reels.length) return;
    if (controllers.containsKey(index)) return;

    final reel = reels[index];
    try {
      final VideoPlayerController controller;
      if (reel.videoUrl.startsWith('http://') || reel.videoUrl.startsWith('https://')) {
        controller = VideoPlayerController.networkUrl(Uri.parse(reel.videoUrl));
      } else {
        controller = VideoPlayerController.file(File(reel.videoUrl));
      }
      controllers[index] = controller;
      
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(isMuted ? 0.0 : 1.0);
      initializedMap[index] = true;
      notifyListeners();
    } catch (e) {
      initializedMap[index] = false;
      notifyListeners();
    }
  }

  /// Handle Page Change on Vertical Swipe
  void onPageChanged(int newIndex) {
    if (newIndex == currentIndex) return;

    // Pause previous video
    controllers[currentIndex]?.pause();

    currentIndex = newIndex;

    // Play new current video if ready, or initialize and play
    if (controllers.containsKey(newIndex) && (initializedMap[newIndex] ?? false)) {
      controllers[newIndex]?.play();
    } else {
      _initializeControllerAtIndex(newIndex).then((_) {
        if (currentIndex == newIndex) {
          controllers[newIndex]?.play();
        }
      });
    }

    // Preload next and previous video controllers for instant playback
    _initializeControllerAtIndex(newIndex + 1);
    _initializeControllerAtIndex(newIndex - 1);

    // Dispose out of bound controllers (more than 2 items away)
    _cleanupFarControllers(newIndex);

    // Trigger pagination load if user is near end (e.g. index >= length - 3)
    if (newIndex >= reels.length - 3 && hasMore) {
      loadMoreReels();
    }

    notifyListeners();
  }

  /// Clean up video controllers out of range
  void _cleanupFarControllers(int activeIndex) {
    final keysToRemove = <int>[];
    controllers.forEach((index, controller) {
      if ((index - activeIndex).abs() > 2) {
        controller.pause();
        controller.dispose();
        keysToRemove.add(index);
      }
    });

    for (final key in keysToRemove) {
      controllers.remove(key);
      initializedMap.remove(key);
    }
  }

  /// Toggle Audio Mute / Unmute
  void toggleMute() {
    isMuted = !isMuted;
    controllers.forEach((_, controller) {
      controller.setVolume(isMuted ? 0.0 : 1.0);
    });
    notifyListeners();
  }

  /// Toggle Play / Pause on single tap
  void togglePlayPause(int index) {
    final controller = controllers[index];
    if (controller != null && controller.value.isInitialized) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
      notifyListeners();
    }
  }

  /// Retry initializing failed video
  void retryVideo(int index) {
    controllers[index]?.dispose();
    controllers.remove(index);
    initializedMap.remove(index);
    _initializeControllerAtIndex(index).then((_) {
      if (currentIndex == index) {
        controllers[index]?.play();
      }
    });
  }

  /// Handle User Actions (Like, Save, Follow)
  void toggleLike(int index) {
    if (index >= 0 && index < reels.length) {
      _repository.toggleLike(reels[index]);
      notifyListeners();
    }
  }

  void toggleSave(int index) {
    if (index >= 0 && index < reels.length) {
      _repository.toggleSave(reels[index]);
      notifyListeners();
    }
  }

  void toggleFollow(int index) {
    if (index >= 0 && index < reels.length) {
      _repository.toggleFollow(reels[index]);
      notifyListeners();
    }
  }

  /// Handle App Lifecycle (Background / Foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive) {
      controllers[currentIndex]?.pause();
    } else if (lifecycleState == AppLifecycleState.resumed &&
        state == ReelsPageState.success) {
      controllers[currentIndex]?.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controllers.forEach((_, controller) => controller.dispose());
    controllers.clear();
    pageController.dispose();
    super.dispose();
  }
}
