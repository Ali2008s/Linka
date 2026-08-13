class ReelModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String userId;
  final String username;
  final String userDisplayName;
  final String userAvatar;
  final bool verified;
  final String caption;
  final List<String> hashtags;
  int likesCount;
  int commentsCount;
  int sharesCount;
  int viewsCount;
  final String? audioId;
  final String? audioName;
  final String? audioAuthor;
  final String? audioCoverUrl;
  final DateTime createdAt;
  bool isLiked;
  bool isSaved;
  bool isFollowing;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.userId,
    required this.username,
    required this.userDisplayName,
    required this.userAvatar,
    this.verified = false,
    required this.caption,
    this.hashtags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.audioId,
    this.audioName,
    this.audioAuthor,
    this.audioCoverUrl,
    required this.createdAt,
    this.isLiked = false,
    this.isSaved = false,
    this.isFollowing = false,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      userDisplayName: json['userDisplayName']?.toString() ?? json['username']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString() ?? '',
      verified: json['verified'] == true,
      caption: json['caption']?.toString() ?? '',
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'].map((e) => e.toString()))
          : [],
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      audioId: json['audioId']?.toString(),
      audioName: json['audioName']?.toString(),
      audioAuthor: json['audioAuthor']?.toString(),
      audioCoverUrl: json['audioCoverUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isLiked: json['isLiked'] == true,
      isSaved: json['isSaved'] == true,
      isFollowing: json['isFollowing'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'userId': userId,
      'username': username,
      'userDisplayName': userDisplayName,
      'userAvatar': userAvatar,
      'verified': verified,
      'caption': caption,
      'hashtags': hashtags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'audioId': audioId,
      'audioName': audioName,
      'audioAuthor': audioAuthor,
      'audioCoverUrl': audioCoverUrl,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
      'isSaved': isSaved,
      'isFollowing': isFollowing,
    };
  }

  ReelModel copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? userId,
    String? username,
    String? userDisplayName,
    String? userAvatar,
    bool? verified,
    String? caption,
    List<String>? hashtags,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    String? audioId,
    String? audioName,
    String? audioAuthor,
    String? audioCoverUrl,
    DateTime? createdAt,
    bool? isLiked,
    bool? isSaved,
    bool? isFollowing,
  }) {
    return ReelModel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatar: userAvatar ?? this.userAvatar,
      verified: verified ?? this.verified,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      audioId: audioId ?? this.audioId,
      audioName: audioName ?? this.audioName,
      audioAuthor: audioAuthor ?? this.audioAuthor,
      audioCoverUrl: audioCoverUrl ?? this.audioCoverUrl,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
