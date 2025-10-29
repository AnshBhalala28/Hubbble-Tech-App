import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:wavee/comman/colors.dart';

class VideoView extends StatefulWidget {
  final String? videoUrl;

  const VideoView({super.key, this.videoUrl});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    _controller = VideoPlayerController.network(widget.videoUrl!);

    await _controller!.initialize().catchError((_) {
      setState(() => _isLoading = false);
    });

    _controller!.addListener(() {
      // Show loader during buffering
      if (mounted) {
        setState(() {
          _isLoading = !_controller!.value.isInitialized ||
              _controller!.value.isBuffering;
        });
      }
    });

    _controller!.play();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maincolor,
      body: Column(
        children: [
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 25.w),
                Text(
                  'View Video',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: "task",
                    letterSpacing: 1,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: Center(
              child: _controller == null
                  ? _errorWidget("No video URL provided")
                  : Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller!.value.isInitialized)
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  if (_controller!.value.isInitialized &&
                      !_controller!.value.isPlaying &&
                      !_isLoading)
                    Icon(
                      Icons.play_circle_fill,
                      color: Colors.white.withOpacity(0.8),
                      size: 80,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontFamily: "task",
          fontSize: 15.sp,
        ),
      ),
    );
  }
}
