import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

class RecordingService extends ChangeNotifier {
  final _audioRecorder = Record();
  bool _isRecording = false;
  String? _recordingPath;
  DateTime? _startTime;
  String _selectedBitrate = '128000';

  bool get isRecording => _isRecording;
  String? get recordingPath => _recordingPath;
  DateTime? get startTime => _startTime;
  String get selectedBitrate => _selectedBitrate;

  void setSelectedBitrate(String bitrate) {
    _selectedBitrate = bitrate;
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      await _audioRecorder.start(
        numChannels: 1,
        encoder: AudioEncoder.aacLc,
        bitRate: int.parse(_selectedBitrate),
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
