// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_animated_buttons/widgets/pretty_shadow_button.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  RecorderScreenState createState() => RecorderScreenState();
}

class RecorderScreenState extends State<RecorderScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _isRecording = false;
  bool _isRecorded = false;
  String? _filePath;

  late AnimationController _animationController;

  Timer? _timer;
  int _recordDuration = 0;

  Duration _playbackPosition = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _recorder.openRecorder();
  }

  Future<void> _initializePlayer() async {
    await _player.openPlayer();
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
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
    _startTimer();
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _stopTimer();
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
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _playbackPosition = Duration.zero;
          });
        },
      );
      _player.setSubscriptionDuration(Duration(milliseconds: 100));
      _player.onProgress!.listen((PlaybackDisposition disposition) {
        setState(() {
          _playbackPosition = disposition.position;
          _playbackDuration = disposition.duration;
        });
      });
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _stopPlayback() async {
    await _player.stopPlayer();
    setState(() {
      _isPlaying = false;
      _playbackPosition = Duration.zero;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _animationController.dispose();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                if (_isRecording)
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          double size = 50 + (_animationController.value * 20);
                          return Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.5),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Recording: $_recordDuration s',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                if (_isRecorded && !_isRecording)
                  Column(
                    children: [
                      Slider(
                        min: 0,
                        max: _playbackDuration.inSeconds > 0
                            ? _playbackDuration.inSeconds.toDouble()
                            : 1.0,
                        value: _playbackPosition.inSeconds.toDouble().clamp(
                              0.0,
                              _playbackDuration.inSeconds > 0
                                  ? _playbackDuration.inSeconds.toDouble()
                                  : 1.0,
                            ),
                        onChanged: (value) async {
                          if (_isPlaying) {
                            await _player.seekToPlayer(
                              Duration(seconds: value.toInt()),
                            );
                          }
                        },
                      ),
                      Text(
                        _isPlaying
                            ? 'Playing: ${_playbackPosition.inSeconds}s / ${_playbackDuration.inSeconds}s'
                            : 'Recorded: $_recordDuration s',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_isPlaying)
                            PrettyShadowButton(
                              label: 'Play Audio',
                              onPressed: _playRecording,
                              icon: Icons.play_arrow,
                              shadowColor: Colors.green,
                            ),
                          if (_isPlaying)
                            PrettyShadowButton(
                              label: 'Stop Playback',
                              onPressed: _stopPlayback,
                              icon: Icons.stop,
                              shadowColor: Colors.red,
                            ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
