import 'package:flutter/material.dart';

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
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
