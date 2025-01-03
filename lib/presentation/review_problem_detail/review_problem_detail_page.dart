import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../model/problem.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../common/custom_menu_bar.dart';

class ReviewProblemDetailPage extends StatefulWidget {
  static const routeName = '/review_problem_detail';
  final ReviewProblem reviewProblem;

  const ReviewProblemDetailPage({
    super.key,
    required this.reviewProblem,
  });

  @override
  State<ReviewProblemDetailPage> createState() =>
      _ReviewProblemDetailPageState();
}

class _ReviewProblemDetailPageState extends State<ReviewProblemDetailPage> {
  final AppCubit _appCubit = getIt.get();
  bool _hideUi = false;
  late bool _hideMemo = widget.reviewProblem.memo.isEmpty;
  int _currentIndex = 0;
  double _imageX = 0;
  double _imageY = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final problem = widget.reviewProblem;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: problem.imagePaths.length,
            builder: (_, index) => PhotoViewGalleryPageOptions(
              onTapUp: (_, __, ___) => _onPhotoViewTapUp(),
              onScaleEnd: _onPhotoViewScaleEnd,
              imageProvider: CachedNetworkImageProvider(
                problem.imagePaths[index],
              ),
              errorBuilder: (_, __, ___) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '사진을 불러올 수 없어요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '오프라인 상태일 때에는 온라인 상태에서 열어본 적이 있는 사진만 볼 수 있어요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            onPageChanged: _onPhotoChanged,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: _hideUi ? const SizedBox.shrink() : _buildMenuBar(),
            ),
          ),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: _hideUi ? const SizedBox.shrink() : _buildPageIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBar() {
    final problem = widget.reviewProblem;
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      margin: const EdgeInsets.only(bottom: 40),
      color:
          _hideMemo ? Colors.black.withAlpha(102) : Colors.black.withAlpha(179),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomMenuBar(
            title: problem.title,
            lightText: true,
            actionButtons: [
              ActionButton(
                icon: const Icon(Icons.download),
                tooltip: '이미지 다운로드',
                onPressed: _onDownloadPressed,
              ),
              ActionButton(
                icon: const Icon(Icons.description),
                tooltip: '메모 보기/숨기기',
                onPressed: _onMemoIconPressed,
              ),
            ],
          ),
          _hideMemo
              ? const SizedBox.shrink()
              : Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        problem.memo,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.black38,
        ),
        child: Text(
          '${_currentIndex + 1}/${widget.reviewProblem.imagePaths.length}',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onPhotoViewTapUp() {
    setState(() {
      _hideUi = !_hideUi;
    });
  }

  void _onPhotoViewScaleEnd(
      _, ScaleEndDetails details, PhotoViewControllerValue controllerValue) {
    double x = controllerValue.position.dx;
    double y = controllerValue.position.dy;
    if ((x - _imageX).abs() < 2 &&
        (y - _imageY).abs() < 2 &&
        details.pointerCount == 0 &&
        details.velocity.pixelsPerSecond.distance == 0) {
      _onPhotoViewTapUp();
    }
    _imageX = x;
    _imageY = y;
  }

  void _onPhotoChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDownloadPressed() async {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사용할 수 없는 기능이에요.',
        dismissOnTap: true,
      );
      return;
    }

    final appDocDir = await getTemporaryDirectory();
    String savePath = "${appDocDir.path}/temp.jpg";
    String imageUrl = widget.reviewProblem.imagePaths[_currentIndex];

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('다운로드하는 중입니다...'),
        ),
      );
    }
    await Dio().download(imageUrl, savePath);
    await ImageGallerySaver.saveFile(savePath, name: DateTime.now().toString());
    await File(savePath).delete();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('저장되었습니다.')),
      );
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
