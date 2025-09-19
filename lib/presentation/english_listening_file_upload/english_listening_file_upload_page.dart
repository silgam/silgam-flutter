import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ui/ui.dart';

import '../../util/injection.dart';
import 'cubit/english_listening_file_upload_cubit.dart';
import 'scrollable_waveform.dart';

class EnglishListeningFileUploadPage extends StatefulWidget {
  const EnglishListeningFileUploadPage({super.key});

  static const routeName = '/english_listening_file_upload';

  @override
  State<EnglishListeningFileUploadPage> createState() => _EnglishListeningFileUploadPageState();
}

class _EnglishListeningFileUploadPageState extends State<EnglishListeningFileUploadPage> {
  final EnglishListeningFileUploadCubit _cubit = getIt.get();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _waveformScrollController = ScrollController();

  Duration? _audioDuration;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _waveformScrollController.dispose();
    super.dispose();
  }

  void _onIsPlayingChanged(bool isPlaying) {
    final audioDuration = _audioDuration;
    if (audioDuration == null) return;

    if (isPlaying) {
      final remainingDuration = audioDuration - _audioPlayer.position;

      _audioPlayer.play();
      _waveformScrollController.animateTo(
        _waveformScrollController.position.maxScrollExtent,
        duration: remainingDuration,
        curve: Curves.linear,
      );
    } else {
      _audioPlayer.pause();
      _waveformScrollController.position.hold(() {});
    }
  }

  Future<void> _onPickFileButtonPressed() async {
    // TODO: pickFiles() options
    final files = await FilePicker.platform.pickFiles();
    final path = files?.files.first.path;
    if (path == null) return;

    // TODO: 코드 분리
    _audioDuration = await _audioPlayer.setFilePath(path);

    final waveformData = await AudioWaveformsInterface.instance.extractWaveformData(
      key: shortHash(UniqueKey()),
      path: path,
      noOfSamples: 2000, // TODO
    );

    _cubit.updateWaveformData(waveformData);
  }

  void _onPlayButtonPressed() {
    _cubit.togglePlayPause();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocListener<EnglishListeningFileUploadCubit, EnglishListeningFileUploadState>(
        listenWhen: (previous, current) => previous.isPlaying != current.isPlaying,
        listener: (context, state) {
          _onIsPlayingChanged(state.isPlaying);
        },
        child: PageLayout(
          title: '영어 듣기 음원 설정',
          onBackPressed: () => Navigator.pop(context),
          child: Column(
            children: [
              BlocSelector<
                EnglishListeningFileUploadCubit,
                EnglishListeningFileUploadState,
                List<double>?
              >(
                selector: (state) => state.waveformData,
                builder: (context, waveformData) {
                  if (waveformData == null) {
                    return const SizedBox.shrink();
                  }

                  return ScrollableWaveform(
                    waveformData: waveformData,
                    scrollController: _waveformScrollController,
                  );
                },
              ),
              OutlinedButton(onPressed: _onPickFileButtonPressed, child: const Text('Upload File')),
              BlocSelector<EnglishListeningFileUploadCubit, EnglishListeningFileUploadState, bool>(
                selector: (state) => state.isPlaying,
                builder: (context, isPlaying) {
                  return IconButton(
                    onPressed: _onPlayButtonPressed,
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
