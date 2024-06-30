import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recording_service.dart';
import 'file_management_service.dart';

class RecordingControlsWidget extends StatefulWidget {
  final AnimationController animationController;
  final VoidCallback onRecordingComplete;

  const RecordingControlsWidget({
    super.key,
    required this.animationController,
    required this.onRecordingComplete,
  });

  @override
  RecordingControlsWidgetState createState() => RecordingControlsWidgetState();
}

class RecordingControlsWidgetState extends State<RecordingControlsWidget> {
  String selectedBitrate = '128000';
  final List<String> bitrates = [
    '12000',
    '24000',
    '48000',
    '96000',
    '128000',
    '192000',
    '256000'
  ];

  Widget _buildRecordingIndicator() {
    final recordingText =
        'Recording at ${int.parse(selectedBitrate) ~/ 1000} kbps';
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red
                    .withOpacity(0.5 + 0.5 * widget.animationController.value),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              recordingText,
              // show bitrate while recording
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBitrateDropdown() {
    return DropdownButton<String>(
      value: selectedBitrate,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedBitrate = newValue;
          });
        }
      },
      items: bitrates.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('${int.parse(value) ~/ 1000} kbps'),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordingService = Provider.of<RecordingService>(context);
    final fileManagementService = Provider.of<FileManagementService>(context);

    return Column(
      children: [
        if (!recordingService.isRecording) _buildBitrateDropdown(),
        const SizedBox(height: 20),
        if (recordingService.isRecording) ...[
          _buildRecordingIndicator(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await recordingService.stopRecording();
              await fileManagementService.updateRecordingDetails(
                recordingService.recordingPath,
                recordingService.startTime!,
              );
              widget.onRecordingComplete();
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop Recording'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ] else
          ElevatedButton.icon(
            onPressed: () => recordingService.startRecording(selectedBitrate),
            icon: const Icon(Icons.mic),
            label: const Text('Start Recording'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
      ],
    );
  }

  String get currentBitrate => selectedBitrate;
}
