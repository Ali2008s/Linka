import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/glass_nav_bar.dart';
import 'reels_tab.dart';
import 'chats_tab.dart';
import 'wallet_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<GlassNavItem> _navItems = [
    GlassNavItem(
      icon: CupertinoIcons.play_rectangle,
      activeIcon: CupertinoIcons.play_rectangle_fill,
      label: 'الرئيسية',
    ),
    GlassNavItem(
      icon: CupertinoIcons.bubble_left_bubble_right,
      activeIcon: CupertinoIcons.bubble_left_bubble_right_fill,
      label: 'المحادثات',
    ),
    GlassNavItem(
      icon: CupertinoIcons.creditcard,
      activeIcon: CupertinoIcons.creditcard_fill,
      label: 'المحفظة',
    ),
    GlassNavItem(
      icon: CupertinoIcons.person_circle,
      activeIcon: CupertinoIcons.person_circle_fill,
      label: 'الملف',
    ),
  ];

  static const List<Widget> _pages = [
    ReelsTab(),
    ChatsTab(),
    WalletTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0F0F12),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
