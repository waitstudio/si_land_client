import 'package:flutter/material.dart';

import '../../../../domain/entities/streamer.dart';
import '../../../components/live_badge.dart';
import '../../../components/streamer_avatar.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_scale.dart';

/// 主播订阅卡片
class StreamerTile extends StatelessWidget {
  const StreamerTile({
    super.key,
    required this.streamer,
  });

  final Streamer streamer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgR),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamerAvatar(
              avatar: streamer.avatar,
              nickname: streamer.nickname,
              radius: 28,
            ),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    streamer.nickname,
                    style: const TextStyle(
                      fontSize: AppTextScale.title,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    '抖音号：${streamer.douyinId}',
                    style: const TextStyle(
                      fontSize: AppTextScale.hint,
                      color: AppColors.subInk,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            LiveBadge(live: streamer.live),
          ],
        ),
      ),
    );
  }
}
