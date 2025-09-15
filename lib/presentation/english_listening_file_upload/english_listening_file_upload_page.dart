import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../util/injection.dart';
import 'cubit/english_listening_file_upload_cubit.dart';
import 'waveform_painter.dart';

class EnglishListeningFileUploadPage extends StatelessWidget {
  EnglishListeningFileUploadPage({super.key});

  static const routeName = '/english_listening_file_upload';

  final EnglishListeningFileUploadCubit _cubit = getIt.get();

  Future<void> _onPickFileButtonPressed() async {
    // TODO: pickFiles() options
    final files = await FilePicker.platform.pickFiles();
    final path = files?.files.first.path;
    if (path == null) return;

    final waveformData = await AudioWaveformsInterface.instance.extractWaveformData(
      key: shortHash(UniqueKey()),
      path: path,
      noOfSamples: 5000, // TODO
    );

    _cubit.updateWaveformData(waveformData);
  }

  void _onPlayButtonPressed() {
    // _cubit.playWaveform();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: PageLayout(
        title: '영어 듣기 음원 설정',
        onBackPressed: () => Navigator.pop(context),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:
                  BlocSelector<
                    EnglishListeningFileUploadCubit,
                    EnglishListeningFileUploadState,
                    List<double>?
                  >(
                    selector: (state) => state.waveformData,
                    builder: (context, waveformData) {
                      final waveformPainter = WaveformPainter(waveformData: waveformData ?? []);

                      return CustomPaint(
                        size: Size(waveformPainter.intrinsicWidth, 400),
                        painter: waveformPainter,
                      );
                    },
                  ),
            ),
            OutlinedButton(onPressed: _onPickFileButtonPressed, child: const Text('Upload File')),
            IconButton(onPressed: _onPlayButtonPressed, icon: const Icon(Icons.play_arrow)),
          ],
        ),
      ),
    );
  }
}
