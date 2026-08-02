import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          itemCount: sections.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  if (updatedAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '更新日期：$updatedAt',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              );
            }
            final s = sections[i - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.body,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.7,
                      color: Color(0xFF5A5A5A),
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
