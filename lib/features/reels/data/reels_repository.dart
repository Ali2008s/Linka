import 'reels_service.dart';
import '../models/reel_model.dart';
import '../models/comment_model.dart';

class ReelsRepository {
  final ReelsService _service;

  ReelsRepository({ReelsService? service}) : _service = service ?? ReelsService();

  Future<ReelFetchResult> getReels({int page = 1, int limit = 10}) async {
    return await _service.fetchReels(page: page, limit: limit);
  }

  Future<List<CommentModel>> getComments(String reelId) async {
    return await _service.fetchComments(reelId);
  }

  void toggleLike(ReelModel reel) {
    if (reel.isLiked) {
      reel.isLiked = false;
      reel.likesCount = (reel.likesCount - 1).clamp(0, 99999999);
    } else {
      reel.isLiked = true;
      reel.likesCount += 1;
    }
  }

  void toggleSave(ReelModel reel) {
    reel.isSaved = !reel.isSaved;
  }

  void toggleFollow(ReelModel reel) {
    reel.isFollowing = !reel.isFollowing;
  }

  CommentModel addComment(String reelId, String text) {
    return CommentModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      reelId: reelId,
      userId: 'current_user',
      username: 'أنت',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      text: text,
      createdAt: DateTime.now(),
      likesCount: 0,
      isLiked: false,
    );
  }
}
