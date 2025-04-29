import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmerScreen extends StatefulWidget {
  const VideoTrimmerScreen({super.key, required this.vid});
  final File vid;

  @override
  State<VideoTrimmerScreen> createState() => _VideoTrimmerScreenState();
}

class _VideoTrimmerScreenState extends State<VideoTrimmerScreen> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0;
  double _endValue = 0;

  bool _isPlaying = false;
  final bool _progressVisibility = false;

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.vid);
  }

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit video'),
        actions: [
          TextButton(
            onPressed: () {
              _trimmer.saveTrimmedVideo(
                startValue: _startValue,
                endValue: _endValue,
                onSave: (val) {
                  if (val != null) {
                    File trimmedVideoFile = File(val);
                    context.pop(trimmedVideoFile);
                  }
                },
              );
            },
            child: Text('Done'),
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(bottom: 30),
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: _progressVisibility,
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.red,
                ),
              ),
              Expanded(child: VideoViewer(trimmer: _trimmer)),
              Center(
                child: TrimViewer(
                  trimmer: _trimmer,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: const Duration(minutes: 1),
                  onChangeStart: (value) => _startValue = value,
                  onChangeEnd: (value) => _endValue = value,
                  onChangePlaybackState:
                      (value) => setState(() => _isPlaying = value),
                ),
              ),
              TextButton(
                child:
                    _isPlaying
                        ? const Icon(Icons.pause, size: 40, color: Colors.white)
                        : const Icon(
                          Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
                        ),
                onPressed: () async {
                  final playbackState = await _trimmer.videoPlaybackControl(
                    startValue: _startValue,
                    endValue: _endValue,
                  );
                  setState(() {
                    _isPlaying = playbackState;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
