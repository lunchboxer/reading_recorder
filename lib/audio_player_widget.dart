import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'recording_service.dart';
import 'package:provider/provider.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final recordingService = Provider.of<RecordingService>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.play_arrow),
              onPressed: _playerState == PlayerState.playing
                  ? null
                  : () {
                      _audioPlayer.play(
                          DeviceFileSource(recordingService.recordingPath!));
                    },
            ),
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.pause),
              onPressed: _playerState == PlayerState.playing
                  ? () {
                      _audioPlayer.pause();
                    }
                  : null,
            ),
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.stop),
              onPressed: _playerState == PlayerState.playing
                  ? () {
                      _audioPlayer.stop();
                    }
                  : null,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Slider(
            value: _position.inMilliseconds.toDouble(),
            min: 0.0,
            max: _duration.inMilliseconds.toDouble(),
            onChanged: (value) {
              final position = Duration(seconds: value.toInt());
              _audioPlayer.seek(position);
            },
          ),
        ),
        Text('${_formatDuration(_position)} / ${_formatDuration(_duration)}'),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
