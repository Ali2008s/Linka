import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/reels_controller.dart';
import 'create_reel_screen.dart';
import 'widgets/reel_card.dart';
import 'widgets/reels_skeleton.dart';

class ReelsScreen extends StatefulWidget {
  final bool showBackButton;

  const ReelsScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late ReelsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReelsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Body Content depending on state
              _buildBodyState(),

              // Top Translucent Navigation Bar
              _buildTopBar(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBodyState() {
    switch (_controller.state) {
      case ReelsPageState.loading:
        return const ReelsSkeletonWidget();

      case ReelsPageState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFE11D74),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد اتصال بالإنترنت',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _controller.errorMessage ?? 'تعذر جلب الفيديوهات. يرجى إعادة المحاولة.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _controller.loadInitialReels,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: Text(
                    'إعادة المحاولة',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D74),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case ReelsPageState.empty:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_creation_outlined,
                color: Colors.white54,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد فيديوهات حالياً',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );

      case ReelsPageState.success:
        return PageView.builder(
          controller: _controller.pageController,
          scrollDirection: Axis.vertical,
          itemCount: _controller.reels.length,
          onPageChanged: _controller.onPageChanged,
          itemBuilder: (context, index) {
            final reel = _controller.reels[index];
            return ReelCardWidget(
              reel: reel,
              index: index,
              controller: _controller,
            );
          },
        );
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black54, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Right Section: Title & Optional Back button
              Row(
                children: [
                  if (widget.showBackButton || Navigator.canPop(context))
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  Text(
                    'ريلز',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Left Section: Create Reel, Search & Options Buttons
              Row(
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.video_call_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateReelScreen(controller: _controller),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildHeaderIconButton(
                    icon: Icons.search_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('بحث الفيديوهات...', style: GoogleFonts.cairo()),
                          backgroundColor: const Color(0xFF17171C),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildHeaderIconButton(
                    icon: Icons.more_vert_rounded,
                    onTap: () {
                      _showOptionsMenu(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF17171C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Colors.white),
                title: Text('إبلاغ عن محتوى', style: GoogleFonts.cairo(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.not_interested_rounded, color: Colors.white),
                title: Text('غير مهتم', style: GoogleFonts.cairo(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Colors.white),
                title: Text('نسخ الرابط', style: GoogleFonts.cairo(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
