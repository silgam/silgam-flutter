import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
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
                      return CachedNetworkImage(
                        imageUrl: imagePath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        progressIndicatorBuilder: (_, __, progress) => Center(
                          child: CircularProgressIndicator(
                            value: progress.progress,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (_, __, ___) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '이미지를 불러올 수 없어요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '오프라인 상태일 때에는 온라인 상태에서 열어본 적이 있는 이미지만 볼 수 있어요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: Colors.grey.shade300,
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
