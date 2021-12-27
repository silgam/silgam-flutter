import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../model/problem.dart';

class ReviewProblemDetailPage extends StatefulWidget {
  static const routeName = '/review_problem_detail';
  final ReviewProblem reviewProblem;

  const ReviewProblemDetailPage({
    Key? key,
    required this.reviewProblem,
  }) : super(key: key);

  @override
  State<ReviewProblemDetailPage> createState() => _ReviewProblemDetailPageState();
}

class _ReviewProblemDetailPageState extends State<ReviewProblemDetailPage> {
  bool _hideUi = false;
  bool _hideMemo = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    final problem = widget.reviewProblem;
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.black38,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: problem.imagePaths.length,
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (_, index) => PhotoViewGalleryPageOptions(
                onTapUp: _onPhotoViewTapUp,
                imageProvider: NetworkImage(problem.imagePaths[index]),
              ),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: _hideUi ? const SizedBox.shrink() : _buildMenuBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBar() {
    final problem = widget.reviewProblem;
    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.black38,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                type: MaterialType.transparency,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  splashRadius: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  problem.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Material(
                type: MaterialType.transparency,
                child: IconButton(
                  onPressed: _onMemoIconPressed,
                  icon: const Icon(Icons.description),
                  splashRadius: 20,
                  color: Colors.white,
                  tooltip: '메모 보기/숨기기',
                ),
              ),
            ],
          ),
          _hideMemo
              ? const SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    problem.memo,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _onPhotoViewTapUp(_, __, ___) {
    setState(() {
      _hideUi = !_hideUi;
    });
  }

  void _onMemoIconPressed() {
    setState(() {
      _hideMemo = !_hideMemo;
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

class ReviewProblemDetailPageArguments {
  ReviewProblem problem;

  ReviewProblemDetailPageArguments({
    required this.problem,
  });
}
