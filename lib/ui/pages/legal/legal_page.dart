import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_scale.dart';

/// 通用法律文档展示页
///
/// 接收 [title] 与 [sections]（按段落分组的标题与正文），统一渲染。
/// 新增协议类页面时，直接传入内容即可，无需重复实现。
class LegalPage extends StatelessWidget {
  const LegalPage({
    super.key,
    required this.title,
    required this.sections,
    this.updatedAt,
  });

  final String title;
  final List<LegalSection> sections;
  final String? updatedAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl + 4),
          itemCount: sections.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppTextScale.headlineLg,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  if (updatedAt != null) ...[
                    const SizedBox(height: AppSpacing.xs + 2),
                    Text(
                      '更新日期：$updatedAt',
                      style: const TextStyle(
                        fontSize: AppTextScale.footer,
                        color: AppColors.subInk,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            }
            final s = sections[i - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: const TextStyle(
                      fontSize: AppTextScale.bodyLg,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    s.body,
                    style: const TextStyle(
                      fontSize: AppTextScale.hint,
                      height: 1.7,
                      color: AppColors.legalBody,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 一段法律文档内容
class LegalSection {
  final String title;
  final String body;

  const LegalSection({required this.title, required this.body});
}
