import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AiVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const AiVideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _AiVideoPlayerWidgetState createState() => _AiVideoPlayerWidgetState();
}

class _AiVideoPlayerWidgetState extends State<AiVideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(_controller),
              Positioned(
                bottom: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
              ),
            ],
          ),
        )
        : const Center(child: CircularProgressIndicator());
  }
}
