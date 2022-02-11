import 'dart:io';

import 'package:flutter/material.dart';

import '../model/problem.dart';

class ReviewProblemCard extends StatelessWidget {
  final ReviewProblem problem;
  final GestureTapCallback? onTap;

  const ReviewProblemCard({
    Key? key,
    required this.problem,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int imageCount = problem.imagePaths.length;
    String imageCountText;
    if (imageCount == 0) {
      imageCountText = '사진 없음';
    } else {
      imageCountText = '사진 $imageCount개';
    }
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(4),
        elevation: 0,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Stack(
          children: [
            if (problem.imagePaths.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Builder(builder: (context) {
                  String imagePath = problem.imagePaths.first;
                  if (imagePath.startsWith('http')) {
                    return Image.network(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    );
                  } else {
                    return Image.file(
                      File(imagePath),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    );
                  }
                }),
              ),
            if (problem.imagePaths.isEmpty)
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/app_icon/app_icon_transparent.png',
                  width: 100,
                  color: Colors.grey.shade100,
                ),
              ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withAlpha(200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.ideographic,
                children: [
                  Flexible(
                    child: Text(
                      problem.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    imageCountText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
