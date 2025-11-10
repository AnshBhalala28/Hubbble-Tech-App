import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../Ui/CommunityScreen/view/FullScreenVideoPlayer.dart';

class VideoWidget extends StatefulWidget {
  final String videoUrl;
  final bool play;
  final int postId;

  const VideoWidget({
    super.key,
    required this.videoUrl,
    this.play = false,
    required this.postId,
  });

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        if (widget.play) _controller.play();
      });
  }

  @override
  void didUpdateWidget(covariant VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => FullScreenVideoPlayer(
            videoUrl: widget.videoUrl,
            postId: widget.postId,
          ),
        );
      },
      child:
          _controller.value.isInitialized
              ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
