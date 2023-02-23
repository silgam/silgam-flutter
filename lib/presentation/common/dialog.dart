import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

import '../../repository/feedback/feedback_repository.dart';
import '../../repository/user/user_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../purchase_page/purchase_page.dart';

void showExamRecordLimitInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: '/record_list/limit_help_dialog',
    ),
    builder: (context) {
      return BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          return BlocBuilder<IapCubit, IapState>(
            builder: (context, iapState) {
              return AlertDialog(
                title: const Text(
                  '실모 기록 개수 제한 안내',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                content: Text(
                    '실감패스를 이용하시기 전까지는 실모 기록을 ${appState.freeProductBenefit.examRecordLimit}개까지만 저장하실 수 있어요 😭'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                    child: const Text('확인'),
                  ),
                  TextButton(
                    onPressed: () {
                      AnalyticsManager.logEvent(
                        name: '[HomePage-list] Check pass button tapped',
                      );
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                        PurchasePage.routeName,
                        arguments: PurchasePageArguments(
                          product: iapState.activeProducts.first,
                        ),
                      );
                    },
                    child: const Text('실감패스 확인하러 가기'),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}

Future<bool?> showMarketingInfoReceivingConsentDialog(
  BuildContext context, {
  bool isDismissible = false,
}) async {
  return await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    routeSettings: const RouteSettings(
      name: 'marketing_info_receiving_consent_dialog',
    ),
    builder: (_) => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            const Text(
              '실감의 소식을 알림으로 받아보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '실감의 상품 소개, 이벤트 등 유용한 정보들을 푸시알림으로 받아보실 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                '광고성 정보 수신 동의 철회는 앱 내 설정 페이지에서 언제든지 가능합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context, false);
                      await _onMarketingConsentDialogClosed(false);
                      final dateString =
                          DateFormat('yyyy년 M월 d일').format(DateTime.now());
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          '실감의 광고성 정보 수신을 거부하셨습니다. ($dateString)',
                        ),
                      ));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      '괜찮아요',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                      await _onMarketingConsentDialogClosed(true);
                      final dateString =
                          DateFormat('yyyy년 M월 d일').format(DateTime.now());
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          '실감의 광고성 정보 수신에 동의하셨습니다 😀 ($dateString)',
                        ),
                      ));
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      '받을게요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

Future<void> _onMarketingConsentDialogClosed(bool isConsent) async {
  final appCubit = getIt.get<AppCubit>();
  final userRepository = getIt.get<UserRepository>();
  final me = appCubit.state.me;
  if (me == null) return;

  await userRepository.updateMarketingConsent(
    userId: me.id,
    isConsent: isConsent,
  );
  await appCubit.onUserChange();
}

void showSendFeedbackDialog(BuildContext context) {
  final textEditingController = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    routeSettings: const RouteSettings(
      name: 'send_feedback_dialog',
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Text(
                  '실감팀에게 의견을 보내주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '실감팀에게 전달하고 싶은 의견을 무엇이든 적어주세요!\n보내주신 의견은 실감팀이 꼼꼼히 읽어볼게요 🙇‍️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textEditingController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: '구체적으로 써주실수록 좋아요',
                    hintMaxLines: 3,
                    isCollapsed: true,
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.all(12),
                    hintStyle: const TextStyle(
                      height: 1.2,
                      color: Colors.grey,
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () async {
                    final text = textEditingController.text.trim();
                    if (text.isEmpty) {
                      EasyLoading.showToast(
                        '내용을 입력해주세요',
                        dismissOnTap: true,
                      );
                      return;
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        '소중한 의견 감사합니다😆 보내주신 의견은 실감팀이 빠르게 읽어볼게요.',
                      ),
                    ));
                    AnalyticsManager.logEvent(
                      name: '[SendFeedbackDialog] Send Feedback',
                      properties: {
                        'content': text,
                      },
                    );
                    getIt
                        .get<FeedbackRepository>()
                        .sendFeedback(feedback: text);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    '보내기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    },
  );
}
