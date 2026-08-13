import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/reels_repository.dart';
import '../../models/comment_model.dart';

class ReelCommentsSheet extends StatefulWidget {
  final String reelId;
  final int initialCount;

  const ReelCommentsSheet({
    super.key,
    required this.reelId,
    required this.initialCount,
  });

  static void show(BuildContext context, {required String reelId, required int initialCount}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReelCommentsSheet(reelId: reelId, initialCount: initialCount),
    );
  }

  @override
  State<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends State<ReelCommentsSheet> {
  final ReelsRepository _repository = ReelsRepository();
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final list = await _repository.getComments(widget.reelId);
    setState(() {
      _comments = list;
      _isLoading = false;
    });
  }

  void _postComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = _repository.addComment(widget.reelId, text);
    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.72,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF121216).withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'التعليقات',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_comments.length}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE11D74),
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Comments List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE11D74),
                        ),
                      )
                    : _comments.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد تعليقات حتى الآن. كُن أول من يعلق!',
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _comments.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return _buildCommentTile(comment);
                            },
                          ),
              ),

              // Add Comment Input Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181F),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: TextField(
                          controller: _commentController,
                          style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'أضف تعليقاً لطيفاً...',
                            hintStyle: GoogleFonts.cairo(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _postComment(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _postComment,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE11D74),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(comment.userAvatar),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.username,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                comment.text,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'منذ ساعتين',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (comment.isLiked) {
                    comment.isLiked = false;
                    comment.likesCount--;
                  } else {
                    comment.isLiked = true;
                    comment.likesCount++;
                  }
                });
              },
              child: Icon(
                comment.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: comment.isLiked ? const Color(0xFFE11D74) : Colors.white38,
                size: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${comment.likesCount}',
              style: GoogleFonts.cairo(fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
      ],
    );
  }
}
