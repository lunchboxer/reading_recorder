import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playRecording(String path) async {
    try {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          notifyListeners();
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pausePlayback() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
