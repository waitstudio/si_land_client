import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../core/config.dart';
import '../../../state/subscription_state.dart';
import '../../../state/subscription_view_model.dart';
import '../../components/empty_state.dart';
import '../../components/loading_indicator.dart';
import '../../components/toast.dart';
import '../../services/local_notifier.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'widgets/add_subscription_sheet.dart';
import 'widgets/streamer_tile.dart';

/// 主播订阅页（Tab 之一）
///
/// 仅负责 UI 组装与事件转发，业务逻辑由 [SubscriptionViewModel] 处理。
class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubscriptionViewModel>();
    final state = vm.state;
    _listen(vm);

    return Scaffold(
      appBar: AppBar(title: const Text('我的订阅')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.goldDark,
          onRefresh: vm.load,
          child: _body(vm, state),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.goldDark,
        foregroundColor: Colors.white,
        onPressed: state.subscribing ? null : () => _addSubscription(vm),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _body(SubscriptionViewModel vm, SubscriptionState state) {
    if (state.loading && state.streamers.isEmpty) {
      return const Center(child: LoadingIndicator());
    }
    if (state.streamers.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyState(
            icon: Icons.live_tv,
            title: '还没有订阅的主播',
            subtitle: '点击右下角 + 添加抖音主播',
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: state.streamers.length,
      itemBuilder: (context, i) {
        final s = state.streamers[i];
        return Slidable(
          key: ValueKey(s.id),
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: 0.22,
            children: [
              CustomSlidableAction(
                onPressed: (_) => vm.unsubscribe(s.id),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.lgR,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.trash,
                    color: AppColors.live,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          child: StreamerTile(streamer: s),
        );
      },
    );
  }

  Future<void> _addSubscription(SubscriptionViewModel vm) async {
    await showAddSubscriptionSheet(context, vm);
  }

  void _listen(SubscriptionViewModel vm) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = vm.state;
      if (s.pendingNotify != null) {
        final msg = s.pendingNotify!.message;
        // 模拟"后台收到推送"：安排 15 秒后由系统层调度弹通知，
        // 不立即弹 banner——给用户时间切到后台 / 锁屏验证。
        // 真实生产应改用 FCM/APNs 远程推送。
        LocalNotifier.instance.scheduleLive(
          title: '主播开播',
          body: msg,
          delay: AppConstants.notifyScheduleDelaySeconds,
        );
        showToast(context, '已安排 15 秒后通知，请切到后台 / 锁屏验证');
        vm.clearPendingNotify();
        return;
      }
      if (s.error != null) {
        showToast(context, s.error!);
        vm.clearError();
      }
    });
  }
}
