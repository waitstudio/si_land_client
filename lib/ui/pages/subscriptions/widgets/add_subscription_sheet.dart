import 'package:flutter/material.dart';

import '../../../../domain/entities/streamer.dart';
import '../../../../state/subscription_state.dart';
import '../../../../state/subscription_view_model.dart';
import '../../../components/loading_indicator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_scale.dart';
import 'manual_add_section.dart';
import 'popular_streamer_tile.dart';

/// 添加订阅底部弹框
///
/// 上半部分：热门主播列表（按人气降序，每项右侧带订阅按钮）
/// 下半部分：手动输入抖音号订阅（兜底入口）
///
/// 调用方传入 [vm]，sheet 内部直接调用 [SubscriptionViewModel.subscribe]，
/// 订阅成功后热门列表的 popularity 与订阅状态会自动同步。
Future<void> showAddSubscriptionSheet(
  BuildContext context,
  SubscriptionViewModel vm,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (ctx) => _AddSubscriptionSheet(vm: vm),
  );
}

class _AddSubscriptionSheet extends StatefulWidget {
  const _AddSubscriptionSheet({required this.vm});

  final SubscriptionViewModel vm;

  @override
  State<_AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<_AddSubscriptionSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 首次打开拉取热门列表（vm 内部会去重，重复调用安全）
      widget.vm.loadPopular();
    });
  }

  Future<void> _onManualSubscribe(String douyinId) async {
    await widget.vm.subscribe(douyinId);
    // 订阅成功后关闭弹框
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _onPopularSubscribe(Streamer s) async {
    await widget.vm.subscribe(s.douyinId);
    // 不关闭弹框：用户可能连续订阅多个，且能看到状态变化
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    // 直接监听 vm（避免依赖 Provider context 在 ModalBottomSheet 中失效）
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, _) {
        final state = widget.vm.state;
        final subscribedIds = state.streamers.map((s) => s.id).toSet();
        final popular = state.popular;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.78,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const Divider(height: 1, color: AppColors.sheetDivider),
                  Expanded(
                    child: _buildPopularSection(state, popular, subscribedIds),
                  ),
                  const Divider(height: 1, color: AppColors.sheetDivider),
                  ManualAddSection(
                    onSubscribe: _onManualSubscribe,
                    subscribing: state.subscribing,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '添加主播',
              style: TextStyle(
                fontSize: AppTextScale.titleLg,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 22, color: AppColors.subInk),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection(
    SubscriptionState state,
    List<Streamer> popular,
    Set<String> subscribedIds,
  ) {
    if (state.loadingPopular && popular.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: LoadingIndicator(),
        ),
      );
    }
    if (popular.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Text(
            '暂无热门主播，手动输入抖音号添加',
            style: TextStyle(
                fontSize: AppTextScale.hint, color: AppColors.subInk),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xs),
          child: const Row(
            children: [
              Icon(Icons.local_fire_department,
                  size: 16, color: AppColors.goldDark),
              SizedBox(width: AppSpacing.xs),
              Text(
                '热门主播',
                style: TextStyle(
                  fontSize: AppTextScale.hint,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            itemCount: popular.length,
            itemBuilder: (ctx, i) {
              final s = popular[i];
              final subscribed = subscribedIds.contains(s.id);
              return PopularStreamerTile(
                streamer: s,
                subscribed: subscribed,
                onSubscribe: () => _onPopularSubscribe(s),
              );
            },
          ),
        ),
      ],
    );
  }
}
