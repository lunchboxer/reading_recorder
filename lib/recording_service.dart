import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

class RecordingService extends ChangeNotifier {
  final _audioRecorder = Record();
  bool _isRecording = false;
  String? _recordingPath;
  DateTime? _startTime;

  bool get isRecording => _isRecording;
  String? get recordingPath => _recordingPath;
  DateTime? get startTime => _startTime;

  Future<void> startRecording(String bitrate) async {
    if (await _audioRecorder.hasPermission()) {
      await _audioRecorder.start(
        encoder: AudioEncoder.aacLc,
        bitRate: int.parse(bitrate),
      );
      _isRecording = true;
      _startTime = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    _recordingPath = await _audioRecorder.stop();
    _isRecording = false;
    notifyListeners();
  }

  void clearRecordingPath() {
    _recordingPath = null;
    _startTime = null;
    notifyListeners();
  }
}
