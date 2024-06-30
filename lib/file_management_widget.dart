import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recording_service.dart';
import 'file_management_service.dart';

class FileManagementWidget extends StatelessWidget {
  final String selectedBitrate;
  final VoidCallback onFileDeleted;

  const FileManagementWidget({
    super.key,
    required this.selectedBitrate,
    required this.onFileDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final recordingService = Provider.of<RecordingService>(context);
    final fileManagementService = Provider.of<FileManagementService>(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            await fileManagementService
                .deleteRecording(recordingService.recordingPath!);
            onFileDeleted();
          },
          icon: const Icon(Icons.delete),
          label: const Text('Delete Recording'),
        ),
        const SizedBox(height: 20),
        Text('Recording Details:',
            style: Theme.of(context).textTheme.titleLarge),
        Text('Duration: ${fileManagementService.recordingDuration}'),
        Text('File Size: ${fileManagementService.recordingFileSize}'),
        Text('Filename: ${recordingService.recordingPath?.split('/').last}'),
        Text('Bitrate: ${int.parse(selectedBitrate) ~/ 1000} kbps'),
        Text('Created At: ${fileManagementService.recordingCreatedAt}'),
      ],
    );
  }
}