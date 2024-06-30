import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recording_service.dart';
import 'audio_player_widget.dart';
import 'file_management_widget.dart';

class PlaybackPage extends StatelessWidget {
  final VoidCallback onFileDeleted;

  const PlaybackPage({super.key, required this.onFileDeleted});

  @override
  Widget build(BuildContext context) {
    final recordingService = Provider.of<RecordingService>(context);

    if (recordingService.recordingPath == null) {
      return const Center(
        child: Text('No recordings available'),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const AudioPlayerWidget(),
            const SizedBox(height: 20),
            FileManagementWidget(
              selectedBitrate: '128000', // You may want to update this
              onFileDeleted: onFileDeleted,
            ),
          ],
        ),
      ),
    );
  }
}
