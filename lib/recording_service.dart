import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

enum AudioCodec {
  aacLc,
  aacEld,
  aacHe,
  amrNb,
  amrWb,
  opus,
}

class RecordingService extends ChangeNotifier {
  final _audioRecorder = Record();
  bool _isRecording = false;
  String? _recordingPath;
  DateTime? _startTime;
  String _selectedBitrate = '128000';
  AudioCodec _selectedCodec = AudioCodec.aacLc;
  int _samplingRate = 44100;

  bool get isRecording => _isRecording;
  String? get recordingPath => _recordingPath;
  DateTime? get startTime => _startTime;
  String get selectedBitrate => _selectedBitrate;
  AudioCodec get selectedCodec => _selectedCodec;
  int get samplingRate => _samplingRate;

  void setSelectedBitrate(String bitrate) {
    _selectedBitrate = bitrate;
    notifyListeners();
  }

  void setSelectedCodec(AudioCodec codec) {
    _selectedCodec = codec;
    notifyListeners();
  }

  void setSamplingRate(int rate) {
    _samplingRate = rate;
    notifyListeners();
  }

  void onRecordingComplete() {
    notifyListeners();
  }

  AudioEncoder _getAudioEncoder(AudioCodec codec) {
    switch (codec) {
      case AudioCodec.aacLc:
        return AudioEncoder.aacLc;
      case AudioCodec.aacEld:
        return AudioEncoder.aacEld;
      case AudioCodec.aacHe:
        return AudioEncoder.aacHe;
      case AudioCodec.amrNb:
        return AudioEncoder.amrNb;
      case AudioCodec.amrWb:
        return AudioEncoder.amrWb;
      case AudioCodec.opus:
        return AudioEncoder.opus;
    }
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      await _audioRecorder.start(
        numChannels: 1,
        encoder: _getAudioEncoder(_selectedCodec),
        bitRate: int.parse(_selectedBitrate),
        samplingRate: _samplingRate,
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
