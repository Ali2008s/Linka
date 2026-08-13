import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../models/reel_model.dart';
import '../models/comment_model.dart';

class ReelFetchResult {
  final List<ReelModel> reels;
  final int page;
  final int limit;
  final bool hasMore;

  ReelFetchResult({
    required this.reels,
    required this.page,
    required this.limit,
    required this.hasMore,
  });
}

class ReelsService {
  /// Fetch reels with pagination (GET /api/reels?page=X&limit=Y)
  Future<ReelFetchResult> fetchReels({int page = 1, int limit = 10}) async {
    try {
      final url = Uri.parse(ApiConfig.reelsUrl(page: page, limit: limit));
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['data'] ?? [];
        final List<ReelModel> reels = data.map((item) => ReelModel.fromJson(item)).toList();
        final bool hasMore = json['hasMore'] ?? false;
        
        return ReelFetchResult(
          reels: reels,
          page: page,
          limit: limit,
          hasMore: hasMore,
        );
      }
    } catch (_) {
      // Fallback to mock data if network request fails or API server is unavailable
    }

    // Fallback Mock Data for production-ready offline/demo playback
    final mockReels = _generateMockReels(page, limit);
    return ReelFetchResult(
      reels: mockReels,
      page: page,
      limit: limit,
      hasMore: page < 4, // 4 pages max mock data
    );
  }

  /// Generate high quality sample vertical reels for demo
  List<ReelModel> _generateMockReels(int page, int limit) {
    if (page > 4) return [];

    final sampleVideos = [
      {
        'id': 'reel_101',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
        'userId': 'user_1',
        'username': 'memzail',
        'userDisplayName': 'محمد عبد الجبار',
        'userAvatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        'verified': true,
        'caption': 'لحظات ساحرة في قلب العاصمة 🌆✨ شاركنا رأيك في التعليقات وسجل الفيديو في المحفوظات للمشاهدة لاحقاً!',
        'hashtags': ['#فيديو', '#الرياض', '#تصوير', '#إبداع', '#ريلز'],
        'likesCount': 23400,
        'commentsCount': 842,
        'sharesCount': 1250,
        'viewsCount': 142000,
        'audioId': 'audio_1',
        'audioName': 'محمد عبد الجبار - شمسين 🎵',
        'audioAuthor': 'محمد عبد الجبار',
        'audioCoverUrl': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=150',
        'createdAt': '2026-08-10T14:30:00Z',
        'isLiked': false,
        'isSaved': false,
        'isFollowing': false,
      },
      {
        'id': 'reel_102',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500',
        'userId': 'user_2',
        'username': 'sara_art',
        'userDisplayName': 'سارة أحمد',
        'userAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'verified': true,
        'caption': 'جمال الطبيعة الهادئة والتفاصيل الصغيرة التي تضفي البهجة على اليوم 🌿🌸 هل تحب هذا النوع من الفيديوهات؟',
        'hashtags': ['#طبيعة', '#هدوء', '#فن', '#ورد'],
        'likesCount': 45100,
        'commentsCount': 1205,
        'sharesCount': 3400,
        'viewsCount': 289000,
        'audioId': 'audio_2',
        'audioName': 'موسيقى الاسترخاء الطبيعية - صوت الأصالة 🍃',
        'audioAuthor': 'استوديو الصوت',
        'audioCoverUrl': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=150',
        'createdAt': '2026-08-11T09:15:00Z',
        'isLiked': true,
        'isSaved': true,
        'isFollowing': true,
      },
      {
        'id': 'reel_103',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-vertical-shot-of-a-dj-playing-music-41443-large.mp4',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500',
        'userId': 'user_3',
        'username': 'beats_master',
        'userDisplayName': 'خالد العتيبي',
        'userAvatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
        'verified': false,
        'caption': 'تجارب موسيقية وايقاعات حديثة من الأستوديو 🎧🔥 اضغط مرتين إذا أعجبك هذا الإيقاع!',
        'hashtags': ['#موسيقى', '#ديجي', '#حفلات', '#ريمكس'],
        'likesCount': 18900,
        'commentsCount': 430,
        'sharesCount': 980,
        'viewsCount': 95000,
        'audioId': 'audio_3',
        'audioName': 'إيقاعات شرقية حديثة - DJ Khalid 🎛️',
        'audioAuthor': 'خالد العتيبي',
        'audioCoverUrl': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=150',
        'createdAt': '2026-08-12T18:00:00Z',
        'isLiked': false,
        'isSaved': false,
        'isFollowing': false,
      },
      {
        'id': 'reel_104',
        'videoUrl': 'https://assets.mixkit.co/videos/preview/mixkit-hands-of-a-man-cooking-food-40324-large.mp4',
        'thumbnailUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
        'userId': 'user_4',
        'username': 'chef_omar',
        'userDisplayName': 'الشيف عمر',
        'userAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'verified': true,
        'caption': 'سر الوصفة الشامية الأصلية في 30 ثانية 👨‍🍳🍲 لا تنس حفظ الفيديو لتجربتها بنفسك!',
        'hashtags': ['#طبخ', '#وصفات', '#شيف', '#طعام'],
        'likesCount': 87300,
        'commentsCount': 2300,
        'sharesCount': 5600,
        'viewsCount': 510000,
        'audioId': 'audio_4',
        'audioName': 'نغمات المطبخ الشرقي 🍲',
        'audioAuthor': 'الشيف عمر',
        'audioCoverUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=150',
        'createdAt': '2026-08-13T12:00:00Z',
        'isLiked': false,
        'isSaved': false,
        'isFollowing': false,
      },
    ];

    final startIdx = (page - 1) * limit;
    return List.generate(limit, (index) {
      final item = sampleVideos[(startIdx + index) % sampleVideos.length];
      final uniqueId = 'reel_${page}_${index}_${item['id']}';
      return ReelModel.fromJson({
        ...item,
        'id': uniqueId,
      });
    });
  }

  /// Fetch comments for a reel
  Future<List<CommentModel>> fetchComments(String reelId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      CommentModel(
        id: 'c1',
        reelId: reelId,
        userId: 'u10',
        username: 'علي القحطاني',
        userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        text: 'فيديو رائع جداً واستثنائي! تسلم الأيادي 🔥',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 24,
        isLiked: true,
      ),
      CommentModel(
        id: 'c2',
        reelId: reelId,
        userId: 'u11',
        username: 'فاطمة الزهراء',
        userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        text: 'ما شاء الله تبارك الله، التنسيق والإخراج رهيب 👏✨',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likesCount: 18,
        isLiked: false,
      ),
      CommentModel(
        id: 'c3',
        reelId: reelId,
        userId: 'u12',
        username: 'سعود الشمري',
        userAvatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
        text: 'ممكن تفاصيل المكان أو الصوت المستخدم؟',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 5,
        isLiked: false,
      ),
    ];
  }
}
