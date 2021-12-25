import 'dart:io';

import 'package:flutter/material.dart';

import '../model/problem.dart';

class ReviewProblemCard extends StatelessWidget {
  final ReviewProblem problem;
  final GestureTapCallback? onTap;
  final bool imageFromNetwork;

  const ReviewProblemCard({Key? key, required this.problem, this.onTap, this.imageFromNetwork = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  if (imageFromNetwork) {
                    return Image.network(
                      problem.imagePaths.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    );
                  } else {
                    return Image.file(
                      File(problem.imagePaths.first),
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
                borderRadius: const BorderRadius.all(Radius.circular(100)),
                color: Colors.white.withAlpha(200),
              ),
              child: Text(
                problem.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
