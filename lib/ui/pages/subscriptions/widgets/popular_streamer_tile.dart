import 'package:flutter/material.dart';

import '../../../../domain/entities/streamer.dart';
import '../../../components/live_badge.dart';
import '../../../components/streamer_avatar.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_scale.dart';

/// 热门主播列表项
///
/// 布局：头像 | 昵称+LiveBadge / 抖音号(Expanded)+订阅人数 | 订阅按钮
/// 抖音号用 Expanded 占满，避免订阅人数随号长短错位
class PopularStreamerTile extends StatelessWidget {
  const PopularStreamerTile({
    super.key,
    required this.streamer,
    required this.subscribed,
    required this.onSubscribe,
  });

  final Streamer streamer;
  final bool subscribed;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Row(
        children: [
          StreamerAvatar(
            avatar: streamer.avatar,
            nickname: streamer.nickname,
            radius: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        streamer.nickname,
                        style: const TextStyle(
                          fontSize: AppTextScale.bodyLg,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    if (streamer.live)
                      const LiveBadge(live: true, compact: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        '抖音号：${streamer.douyinId}',
                        style: const TextStyle(
                          fontSize: AppTextScale.footer,
                          color: AppColors.subInk,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${streamer.popularity} 人订阅',
                      style: const TextStyle(
                        fontSize: AppTextScale.footer,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          _SubscribeButton(
            subscribed: subscribed,
            onSubscribe: onSubscribe,
          ),
        ],
      ),
    );
  }
}

/// 订阅按钮：未订阅=金色可点 / 已订阅=灰色禁用
class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({
    required this.subscribed,
    required this.onSubscribe,
  });

  final bool subscribed;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    if (subscribed) {
      return FilledButton(
        onPressed: null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.subscribedButton,
          foregroundColor: AppColors.footer,
          disabledBackgroundColor: AppColors.subscribedButton,
          disabledForegroundColor: AppColors.footer,
          minimumSize: const Size(64, 32),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smR),
        ),
        child: const Text('已订阅', style: TextStyle(fontSize: AppTextScale.body)),
      );
    }
    return FilledButton(
      onPressed: onSubscribe,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.goldDark,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 32),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smR),
      ),
      child: const Text('订阅', style: TextStyle(fontSize: AppTextScale.body)),
    );
  }
}
