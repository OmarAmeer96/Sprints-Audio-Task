import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() => runApp(AudioRecorderApp());

class AudioRecorderApp extends StatelessWidget {
  const AudioRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RecorderScreen(),
    );
  }
}

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  RecorderScreenState createState() => RecorderScreenState();
}

class RecorderScreenState extends State<RecorderScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isRecorded = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _initializePlayer() async {
    await _player.openPlayer();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/audio_record.aac';
    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );
    setState(() {
      _isRecording = true;
      _filePath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _isRecorded = true;
    });
  }

  Future<void> _playRecording() async {
    if (_filePath != null) {
      await _player.startPlayer(
        fromURI: _filePath,
        codec: Codec.aacADTS,
      );
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrettyShadowButton(
              label: _isRecording ? 'Stop Recording' : 'Record Audio',
              onPressed: () {
                if (_isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
              icon: _isRecording ? Icons.stop : Icons.mic,
              shadowColor: Colors.red,
            ),
            SizedBox(height: 20),
            if (_isRecorded)
              PrettyShadowButton(
                label: 'Play Audio',
                onPressed: _playRecording,
                icon: Icons.play_arrow,
                shadowColor: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}
