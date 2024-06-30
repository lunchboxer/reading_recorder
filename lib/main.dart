import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'recording_service.dart';
import 'file_management_service.dart';
import 'recording_page.dart';
import 'playback_page.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordingService()),
        ChangeNotifierProvider(create: (_) => FileManagementService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final logger = Logger();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    if (await Permission.microphone.request().isGranted) {
      logger.i('Microphone permission granted');
    } else {
      logger.i('Microphone permission denied');
    }
  }

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
      home: AppContent(toggleTheme: toggleTheme),
    );
  }
}

class AppContent extends StatelessWidget {
  final VoidCallback toggleTheme;

  const AppContent({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final recordingService = Provider.of<RecordingService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            recordingService.recordingPath == null ? 'Recording' : 'Playback'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: recordingService.recordingPath == null
          ? RecordingPage(onRecordingComplete: () {
              // This will trigger a rebuild when recording is complete
              recordingService.onRecordingComplete();
            })
          : PlaybackPage(onFileDeleted: () {
              recordingService.clearRecordingPath();
            }),
    );
  }
}
