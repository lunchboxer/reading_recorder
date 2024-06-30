import 'package:flutter/material.dart';
import 'recording_controls_widget.dart';

class RecordingPage extends StatefulWidget {
  final VoidCallback onRecordingComplete;

  const RecordingPage({super.key, required this.onRecordingComplete});

  @override
  RecordingPageState createState() => RecordingPageState();
}

class RecordingPageState extends State<RecordingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RecordingControlsWidget(
        animationController: _animationController,
        onRecordingComplete: widget.onRecordingComplete,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
