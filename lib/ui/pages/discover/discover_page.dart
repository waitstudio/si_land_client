import 'package:flutter/material.dart';

import '../../components/empty_state.dart';

/// 发现页（Tab 之一）
///
/// 占位页面，后续可接入主播推荐 / 热门直播等内容。
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: const EmptyState(
        icon: Icons.explore,
        title: '敬请期待',
      ),
    );
  }
}
