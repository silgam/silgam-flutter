import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'analog_clock/analog_clock.dart';
import 'model/exam.dart';

class ClockPage extends StatefulWidget {
  static const routeName = '/clock';
  final Exam exam;

  const ClockPage({
    Key? key,
    required this.exam,
  }) : super(key: key);

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  child: IconButton(
                    splashRadius: 20,
                    icon: const Icon(Icons.close),
                    onPressed: _onCloseButtonPressed,
                    color: Colors.white,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 24),
                  child: OutlinedButton(
                    child: const Text(
                      '건너뛰기',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    onPressed: _onSkipButtonPressed,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      primary: Colors.white,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const WristWatch(),
          Flexible(child: Container()),
        ],
      ),
    );
  }

  void _onCloseButtonPressed() {
    Navigator.pop(context);
  }

  void _onSkipButtonPressed() {}

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

class WristWatch extends StatelessWidget {
  const WristWatch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 330,
      child: Stack(
        children: [
          SvgPicture.asset(
            'assets/wrist_watch.svg',
            fit: BoxFit.fitWidth,
          ),
          Container(
            alignment: Alignment.center,
            child: const FractionallySizedBox(
              widthFactor: 0.77,
              child: AnalogClock(borderWidth: 0),
            ),
          ),
        ],
      ),
    );
  }
}

class ClockPageArguments {
  final Exam exam;

  ClockPageArguments(this.exam);
}
