import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
