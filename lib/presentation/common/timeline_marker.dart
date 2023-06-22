import 'package:flutter/material.dart';

class TimelineMarker extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const TimelineMarker({
    super.key,
    this.width = 8,
    this.height = 12,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: TimelineMarkerClipper(),
        child: Container(
          width: width,
          height: height,
          color: color,
        ),
      ),
    );
  }
}

class TimelineMarkerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 3 / 5);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height * 3 / 5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TimelineMarkerClipper oldClipper) => false;
}
