import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class FileManagementService extends ChangeNotifier {
  final Logger _logger = Logger();
  String? _recordingDuration;
  String? _recordingFileSize;
  String? _recordingCreatedAt;

  String? get recordingDuration => _recordingDuration;
  String? get recordingFileSize => _recordingFileSize;
  String? get recordingCreatedAt => _recordingCreatedAt;

  Future<void> updateRecordingDetails(String? path, DateTime startTime) async {
    if (path != null) {
      final file = File(path);
      final fileStat = await file.stat();

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _recordingDuration = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
      _recordingFileSize = '${(fileStat.size / 1024).toStringAsFixed(2)} KB';
      _recordingCreatedAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(fileStat.modified);
      notifyListeners();
    }
  }

  Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _recordingDuration = null;
        _recordingFileSize = null;
        _recordingCreatedAt = null;
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error deleting recording: $e');
    }
  }
}
