import 'package:flutter/material.dart';

import '../../components/empty_state.dart';

/// 消息页（Tab 之一）
///
/// 占位页面，后续可接入开播通知历史 / 互动消息等内容。
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: const EmptyState(
        icon: Icons.notifications_none,
        title: '敬请期待',
      ),
    );
  }
}
