import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recording App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'Recording App',
        toggleTheme: toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.toggleTheme});

  final String title;
  final VoidCallback toggleTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isRecording = false;
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
  final record = Record();
  final player = AudioPlayer();
  String? recordingPath;
  String? recordingDuration;
  String? recordingFileSize;
  String? recordingCreatedAt;
  final logger = Logger();
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    if (await Permission.microphone.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      logger.i('Microphone permission granted');
    } else {
      logger.i('Microphone permission denied');
      // You can show a dialog here explaining why the app needs the permission
    }
  }

  Future<void> startRecording() async {
    try {
      if (await record.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await record.start(
          encoder: AudioEncoder.aacLc,
          bitRate: int.parse(selectedBitrate),
          samplingRate: 44100,
          path: filePath,
        );
        setState(() {
          isRecording = true;
          recordingPath = filePath;
          startTime = DateTime.now();
        });
      }
    } catch (e) {
      logger.e('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await record.stop();
      setState(() {
        isRecording = false;
      });
      logger.i('Audio recorded to: $path');
      await updateRecordingDetails();
    } catch (e) {
      logger.e('Error stopping recording: $e');
    }
  }

  Future<void> playRecording() async {
    if (recordingPath != null) {
      await player.play(DeviceFileSource(recordingPath!));
    }
  }

  Future<void> deleteRecording() async {
    if (recordingPath != null) {
      final file = File(recordingPath!);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          recordingPath = null;
          recordingDuration = null;
          recordingFileSize = null;
          recordingCreatedAt = null;
        });
      }
    }
  }

  Future<void> updateRecordingDetails() async {
    if (recordingPath != null) {
      final file = File(recordingPath!);
      final fileStat = await file.stat();

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime!);

      setState(() {
        recordingDuration =
            '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
        recordingFileSize = '${(fileStat.size / 1024).toStringAsFixed(2)} KB';
        recordingCreatedAt =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(fileStat.modified);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () {
                if (isRecording) {
                  stopRecording();
                } else {
                  startRecording();
                }
              },
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              label: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
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
                  child: Text('${int.parse(value) ~/ 1000}kbps'),
                );
              }).toList(),
            ),
            if (recordingPath != null && !isRecording) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: playRecording,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Recording'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: deleteRecording,
                icon: const Icon(Icons.delete),
                label: const Text('Delete Recording'),
              ),
              const SizedBox(height: 20),
              Text('Recording Details:',
                  style: Theme.of(context).textTheme.titleLarge),
              Text('Duration: $recordingDuration'),
              Text('File Size: $recordingFileSize'),
              Text('Filename: ${recordingPath?.split('/').last}'),
              Text('Bitrate: ${int.parse(selectedBitrate) ~/ 1000}kbps'),
              Text('Created At: $recordingCreatedAt'),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    record.dispose();
    player.dispose();
    super.dispose();
  }
}
