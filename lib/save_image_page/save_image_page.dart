import 'package:flutter/material.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

import '../util/menu_bar.dart';

const double _strokeWidth = 0.5;

class SaveImagePage extends StatelessWidget {
  static const routeName = '/record_detail/save_image';

  const SaveImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const MenuBar(title: '이미지 저장'),
            AspectRatio(
              aspectRatio: 1,
              child: _buildPreview(Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(Color primaryColor) {
    return Container(
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        heightFactor: 0.87,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            image: const DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/paper_texture.png'),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                offset: const Offset(4, 4),
                blurRadius: 20,
              ),
            ],
            border: Border(
              top: BorderSide(color: primaryColor, width: 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '2022. 1. 9. (일)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '힐링캠프 모의고사 시즌1 1회',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '수학',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Divider(color: primaryColor, thickness: _strokeWidth),
              const SizedBox(height: 12),
              Row(
                children: const [
                  SizedBox(width: 12),
                  Expanded(
                    child: _InfoBox(
                      title: 'SCORE',
                      content: '80',
                      suffix: '점',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _InfoBox(
                      title: 'GRADE',
                      content: '2',
                      suffix: '등급',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _InfoBox(
                      title: 'TIME',
                      content: '60',
                      suffix: '분',
                    ),
                  ),
                  SizedBox(width: 12),
                ],
              ),
              const SizedBox(height: 20),
              const _InfoBox(
                title: '틀린 문제',
                content: '12,13',
                longText: true,
              ),
              const SizedBox(height: 20),
              const Expanded(
                child: _InfoBox(
                  title: '피드백',
                  content: '피드백 피드백',
                  longText: true,
                  expands: true,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String content;
  final String? suffix;
  final bool longText;
  final bool expands;

  const _InfoBox({
    Key? key,
    required this.title,
    required this.content,
    this.suffix,
    this.longText = false,
    this.expands = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController? controller;
    String? suffixCaptured = suffix;
    if (suffixCaptured != null) {
      controller = RichTextController(
        text: content + suffixCaptured,
        patternMatchMap: {
          RegExp(suffixCaptured): const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w300,
          ),
        },
        onMatch: (_) {},
      );
    }

    return TextFormField(
      controller: controller,
      initialValue: suffix == null ? content : null,
      textAlign: longText ? TextAlign.start : TextAlign.center,
      readOnly: true,
      enabled: false,
      maxLines: null,
      expands: expands,
      style: TextStyle(
        fontSize: longText ? 12 : 14,
        fontWeight: longText ? FontWeight.w500 : FontWeight.w500,
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: _strokeWidth,
          ),
        ),
        labelText: title,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).primaryColor,
        ),
        contentPadding: EdgeInsets.only(
          top: longText ? 11 : 8,
          bottom: longText ? 10 : 7,
          left: longText ? 12 : 0,
          right: longText ? 12 : 0,
        ),
        floatingLabelAlignment: longText ? null : FloatingLabelAlignment.center,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
