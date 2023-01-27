part of 'main_view.dart';

class _DDaysCard extends StatelessWidget {
  final List<DDayItem> dDayItems;

  const _DDaysCard({
    Key? key,
    required this.dDayItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          for (DDayItem item in dDayItems)
            _buildDDayWidget(item, Theme.of(context).primaryColor),
        ],
      ),
    );
  }

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
}
