class CommentModel {
  final String id;
  final String reelId;
  final String userId;
  final String username;
  final String userAvatar;
  final String text;
  final DateTime createdAt;
  int likesCount;
  bool isLiked;

  CommentModel({
    required this.id,
    required this.reelId,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      reelId: json['reelId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reelId': reelId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'isLiked': isLiked,
    };
  }
}
