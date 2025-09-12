import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class EnglishListeningFileUploadPage extends StatelessWidget {
  const EnglishListeningFileUploadPage({super.key});

  static const routeName = '/english_listening_file_upload';

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '영어 듣기 파일 업로드',
      onBackPressed: () => Navigator.pop(context),
      child: Container(),
    );
  }
}
