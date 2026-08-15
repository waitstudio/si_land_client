import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/unread_badge.dart';
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
    // 全局红点数据源：WS 实时推送 / 冷启动拉取 / 消息页操作均更新它
    final badge = context.watch<UnreadBadge>();
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
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined), label: '发现'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.star_outline), label: '订阅'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(
                badge.badgeLabel,
                style: const TextStyle(fontSize: 10),
              ),
              isLabelVisible: badge.hasUnread,
              child: const Icon(Icons.notifications_none_outlined),
            ),
            label: '消息',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }
}
