import 'dart:io';

import 'package:flutter/material.dart';

import '../../model/problem.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (problem.imagePaths.isNotEmpty)
              Expanded(
                child: SizedBox(
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
              ),
            if (problem.imagePaths.isEmpty)
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/app_icon/app_icon_transparent.png',
                    width: 100,
                    color: Colors.grey.shade100,
                  ),
                ),
              ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.ideographic,
                children: [
                  Expanded(
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
            if (problem.memo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                child: Text(
                  problem.memo.replaceAll('\n', ' '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
