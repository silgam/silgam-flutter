import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../common/custom_card.dart';
import 'cubit/main_cubit.dart';

class DDaysCard extends StatelessWidget {
  const DDaysCard({super.key});

  Widget _buildDDayWidget(DDayItem dDayItem, Color primaryColor) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMEd('ko_KR').format(dDayItem.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dDayItem.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Text(
              'D-${dDayItem.remainingDays == 0 ? 'Day' : dDayItem.remainingDays}',
              style: TextStyle(
                height: 0.4,
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 2,
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withAlpha(30),
              ],
              stops: [dDayItem.progress, dDayItem.progress],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      buildWhen: (previous, current) => previous.dDayItems != current.dDayItems,
      builder: (context, state) {
        if (state.dDayItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return CustomCard(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (DDayItem item in state.dDayItems)
                _buildDDayWidget(item, Theme.of(context).primaryColor),
            ],
          ),
        );
      },
    );
  }
}

class DDayItem {
  final String title;
  final DateTime date;
  final int remainingDays;
  final double progress;

  const DDayItem({
    required this.title,
    required this.date,
    required this.remainingDays,
    required this.progress,
  });
}
