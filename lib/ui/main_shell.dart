import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_scale.dart';
import 'pages/discover/discover_page.dart';
import 'pages/messages/messages_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/subscriptions/subscriptions_page.dart';

/// 主框架：底部 4 Tab 导航
///
/// 用 [IndexedStack] 保持各 Tab 页面状态，切换不重建。
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex.clamp(0, 3);

  static const _pages = <Widget>[
    DiscoverPage(),
    SubscriptionsPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.goldDark,
        unselectedItemColor: AppColors.subInk,
        selectedFontSize: AppTextScale.caption + 1,
        unselectedFontSize: AppTextScale.caption + 1,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined), label: '发现'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_outline), label: '订阅'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_outlined), label: '消息'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }
}
