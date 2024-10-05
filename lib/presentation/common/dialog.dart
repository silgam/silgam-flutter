import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../repository/feedback/feedback_repository.dart';
import '../../repository/user/user_repository.dart';
import '../../util/analytics_manager.dart';
import '../../util/const.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../custom_exam_guide/custom_exam_guide_page.dart';
import '../purchase/purchase_page.dart';

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
              final sellingProduct = iapState.sellingProduct;
              return AlertDialog(
                title: const Text(
                  '실모 기록 개수 제한 안내',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                content: Text(
                  '실감패스를 이용하기 전까지는 실모 기록을 ${appState.freeProductBenefit.examRecordLimit}개까지만 추가/수정할 수 있어요. (${appState.freeProductBenefit.examRecordLimit}개 미만까지 삭제 시 추가/수정 가능)',
                ),
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
                  if (sellingProduct != null)
                    TextButton(
                      onPressed: () {
                        AnalyticsManager.logEvent(
                          name: '[HomePage-list] Check pass button tapped',
                        );
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          PurchasePage.routeName,
                          arguments: PurchasePageArguments(
                            product: sellingProduct,
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

void showLapTimeLimitInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: '/lap_time_limit_help_dialog',
    ),
    builder: (context) {
      return BlocBuilder<IapCubit, IapState>(
        builder: (context, iapState) {
          final sellingProduct = iapState.sellingProduct;
          return AlertDialog(
            title: const Text(
              '랩타임 기능 이용 제한 안내',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              '랩타임 측정 기능은 실감패스 구매 후에 이용 가능해요. (랩타임 기능에 대한 자세한 설명은 실감패스 안내 페이지 참고)',
            ),
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
              if (sellingProduct != null)
                TextButton(
                  onPressed: () {
                    AnalyticsManager.logEvent(
                      name: '[LapTimeLimitHelpDialog] Check pass button tapped',
                    );
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(
                      PurchasePage.routeName,
                      arguments: PurchasePageArguments(product: sellingProduct),
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
}

void showCustomExamNotAvailableDialog(
  BuildContext context, {
  bool isFromCustomExamListPage = false,
}) {
  showDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: '/custom_exam_not_available_dialog',
    ),
    builder: (context) {
      return AlertDialog(
        title: const Text(
          '나만의 과목 이용 제한 안내',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '나만의 과목은 실감패스 구매 후에 이용 가능해요. (자세한 내용은 안내 페이지 참고)',
        ),
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
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                CustomExamGuidePage.routeName,
                arguments: CustomExamGuideArguments(
                  isFromCustomExamListPage: isFromCustomExamListPage,
                ),
              );
            },
            child: const Text('자세히 알아보기'),
          ),
        ],
      );
    },
  );
}

void showAllSubjectsTimetableNotAvailableDialog(BuildContext context) {
  showDialog(
    context: context,
    routeSettings: const RouteSettings(
      name: '/all_subjects_timetable_not_available_dialog',
    ),
    builder: (context) {
      return BlocBuilder<IapCubit, IapState>(
        builder: (context, iapState) {
          final sellingProduct = iapState.sellingProduct;
          return AlertDialog(
            title: const Text(
              '전과목 연속 응시 기능 이용 제한 안내',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              '전과목 연속 응시 기능은 실감패스 구매 후에 이용 가능해요. (전과목 연속 응시 기능에 대한 자세한 설명은 실감패스 안내 페이지 참고)',
            ),
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
              if (sellingProduct != null)
                TextButton(
                  onPressed: () {
                    AnalyticsManager.logEvent(
                      name:
                          '[AllSubjectsTimetableNotAvailableDialog] Check pass button tapped',
                    );
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(
                      PurchasePage.routeName,
                      arguments: PurchasePageArguments(product: sellingProduct),
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
}

Future<void> showMarketingInfoReceivingConsentDialog(
  BuildContext context, {
  bool isDismissible = false,
}) async {
  await showModalBottomSheet(
    context: context,
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
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 12),
            const Text(
              '실감의 이벤트, 할인 정보 등 유용한 정보들을 푸시알림으로 받아보실 수 있어요.',
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
            OutlinedButton(
              onPressed: () async {
                Navigator.pop(context);
                AnalyticsManager.logEvent(
                  name:
                      '[MarketingInfoReceivingConsentDialog] Receive button tapped',
                );
                await changeMarketingInfoReceivingConsentStatus(
                  context,
                  true,
                );
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
                '좋아요!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                AnalyticsManager.logEvent(
                  name:
                      '[MarketingInfoReceivingConsentDialog] Close button tapped',
                );
                await changeMarketingInfoReceivingConsentStatus(
                  context,
                  false,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                visualDensity: VisualDensity.compact,
                splashFactory: NoSplash.splashFactory,
                shape: const StadiumBorder(),
              ),
              child: Text(
                '괜찮아요',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> changeMarketingInfoReceivingConsentStatus(
  BuildContext context,
  bool isConsent,
) async {
  final appCubit = getIt.get<AppCubit>();
  if (appCubit.state.isOffline) {
    EasyLoading.showToast(
      '오프라인 상태에서는 사용할 수 없는 기능이에요.',
      dismissOnTap: true,
    );
    return;
  }

  final me = appCubit.state.me;
  if (me == null) return;

  final userRepository = getIt.get<UserRepository>();
  await userRepository.updateMarketingConsent(
    userId: me.id,
    isConsent: isConsent,
  );
  await appCubit.onUserChange();

  final dateString = DateFormat('yyyy년 M월 d일').format(DateTime.now());
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      isConsent
          ? '실감의 광고성 정보 수신에 동의하셨습니다 😀 ($dateString)'
          : '실감의 광고성 정보 수신을 거부하셨습니다. ($dateString)',
    ),
  ));
}

void showSendFeedbackDialog(BuildContext context) {
  final AppCubit appCubit = getIt.get();
  if (appCubit.state.isOffline) {
    EasyLoading.showToast(
      '오프라인 상태에서는 사용할 수 없는 기능이에요.',
      dismissOnTap: true,
    );
  }

  final textEditingController = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        fontFamily: 'NanumSquare',
                      ),
                      children: [
                        const TextSpan(
                          text: '기능상의 오류',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(
                          text: '나 기타 실감팀의 답변이 필요하신 내용은 ',
                        ),
                        TextSpan(
                          text: '카카오톡 채널',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(Uri.parse(urlSupport),
                                mode: LaunchMode.externalApplication),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(
                          text: '을 이용해주세요.',
                        ),
                      ],
                    ),
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
                    if (appCubit.state.isOffline) {
                      EasyLoading.showToast(
                        '오프라인 상태에서는 사용할 수 없는 기능이에요.',
                        dismissOnTap: true,
                      );
                      return;
                    }

                    final text = textEditingController.text.trim();
                    if (text.isEmpty) {
                      EasyLoading.showToast(
                        '내용을 입력해주세요',
                        dismissOnTap: true,
                      );
                      return;
                    }

                    getIt
                        .get<FeedbackRepository>()
                        .sendFeedback(feedback: text);
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
