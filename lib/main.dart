import 'package:flutter/material.dart';
import 'package:sprints_audio_task/recorder_screen.dart';

void main() => runApp(AudioRecorderApp());

class AudioRecorderApp extends StatelessWidget {
  const AudioRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RecorderScreen(),
    );
  }
}
