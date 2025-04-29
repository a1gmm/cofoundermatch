import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uniapp/core/injection.dart';
import 'package:uniapp/data/imports.dart';
import 'package:uniapp/data/source/local/models/current_user.dart';
import 'package:uniapp/presentation/bottom_nav/home_screen.dart';
import 'package:uniapp/presentation/chat/chat_screen.dart';
import 'package:uniapp/presentation/community/community_screen.dart';
import 'package:uniapp/presentation/community/create_post_screen.dart';
import 'package:uniapp/presentation/profile/profile_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  CurrentUser? user;
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _initData();
    _pageController = PageController(
      initialPage: _currentIndex,
      keepPage: true,
    );
    _pageController.addListener(() => setState(() {}));
  }

  _initData() async {
    user = await getIt<UserProfileRepository>().getUserProfile();
    _onChanged();
  }

  _onChanged() => setState(() {});

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomeScreen(),
          CommunityScreen(),
          CreatePostScreen(),
          ChatScreen(user: user),
          ProfileScreen(user: user),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: kBottomNavigationBarHeight,
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            );
          }
          return TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          );
        }),

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        selectedIndex: _currentIndex,
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(Symbols.explore, fill: 1, color: selectedColor),
            icon: const Icon(Symbols.explore, color: Colors.grey),
            label: 'Match',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Symbols.groups,
              fill: 1,
              color: selectedColor,
              size: 26,
            ),
            icon: const Icon(Symbols.groups, color: Colors.grey),
            label: 'Community',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Symbols.add_circle,
              fill: 1,
              color: selectedColor,
              size: 26,
            ),
            icon: const Icon(Symbols.add_circle, color: Colors.grey),
            label: 'Post',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Symbols.chat,
              fill: 1,
              color: selectedColor,
              size: 26,
            ),
            icon: const Icon(Symbols.chat, color: Colors.grey),
            label: 'Chat',
          ),
          NavigationDestination(
            selectedIcon: Icon(
              Symbols.person,
              fill: 1,
              color: selectedColor,
              size: 26,
            ),
            icon: const Icon(Symbols.person, color: Colors.grey),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
