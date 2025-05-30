import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../../comman/check_inernet_connecty.dart';
import '../../../../comman/const.dart';
import '../../../../comman/error_dialog.dart';
import '../Model/DwellTimeModel.dart';
import '../Model/PostAsViewedModel.dart';
import '../Model/postlikemodel.dart';
import '../Provider/community_provider.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final int postId;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.postId,
  }) : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController controller;
  bool isPlayPauseVisible = false;
  bool isLiked = false;
  bool isLikeInProgress = false;
  Timer? hideTimer;
  DateTime? startTime;
  DateTime? endTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    PostAsViewedap();
    controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        controller.play();
      });
    controller.setLooping(true);

    // Load like status from SharedPreferences
    _loadLikeStatus();
  }

  // Load like status from SharedPreferences
  Future<void> _loadLikeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'post_like_${widget.postId}_$userId';
    setState(() {
      isLiked = prefs.getBool(key) ?? false;
    });
  }

  // Save like status to SharedPreferences
  Future<void> _saveLikeStatus(bool liked) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'post_like_${widget.postId}_$userId';
    await prefs.setBool(key, liked);
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    controller.dispose();

    //  Dwell time calculation before screen dispose
    endTime = DateTime.now();
    final dwellDuration = endTime!.difference(startTime!);
    final secondsWatched = dwellDuration.inSeconds;

    if (secondsWatched > 3) {
      // Optional: Filter out quick exits
      videodwelltimeapi(secondsWatched);
    }

    super.dispose();
  }

  void _togglePlayPauseControl() {
    setState(() {
      isPlayPauseVisible = true;
    });

    // Auto-hide the controls after 2 seconds
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isPlayPauseVisible = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  // Function to handle like/unlike
  void handleLikeToggle() {
    if (isLikeInProgress) return; // Prevent multiple rapid clicks

    setState(() {
      isLikeInProgress = true;
    });

    postslikeap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePlayPauseControl,
        child: Stack(
          children: [
            if (controller.value.isInitialized)
              Container(
                width: 100.w,
                height: 100.h,
                child: Center(
                  child: controller.value.aspectRatio > 0
                      ? Transform.scale(
                          scale: _calculateScale(context),
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        )
                      : VideoPlayer(controller),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),
            // Close Button (top-right)
            Positioned(
              top: 3.h,
              right: 3.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Get.back(),
                ),
              ),
            ),

            // Like Button (bottom-right)
            Positioned(
              bottom: 5.h,
              right: 3.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                    size: 24,
                  ),
                  onPressed: isLikeInProgress ? null : handleLikeToggle,
                ),
              ),
            ),

            if (isPlayPauseVisible)
              Center(
                child: GestureDetector(
                  onTap: () {
                    _togglePlayPause();
                    // Reset the timer when explicitly toggling playback
                    hideTimer?.cancel();
                    hideTimer = Timer(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          isPlayPauseVisible = false;
                        });
                      }
                    });
                  },
                  child: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.white.withOpacity(0.8),
                    size: 60,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void postslikeap() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'type': 'post',
      'post_offer_promo_id': widget.postId.toString(),
    };
    print("request parameter : $data");
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().postlikeapi(data).then((response) async {
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            postlikemodel = PostLikeModel.fromJson(responseData);

            // Update like state based on API response
            setState(() {
              isLiked = !isLiked;
              isLikeInProgress = false;
            });

            // Save the updated like status to SharedPreferences
            _saveLikeStatus(isLiked);

            // Show success message
            if (isLiked) {
              print("Post liked successfully");
            } else {
              print("Post unliked successfully");
            }
          } else if (response.statusCode == 429) {
            setState(() {
              isLikeInProgress = false;
            });
            print("Too many requests");
          } else {
            setState(() {
              isLikeInProgress = false;
            });
            print("Internal Server Error");
          }
        });
      } else {
        setState(() {
          isLikeInProgress = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void videodwelltimeapi(int secondsWatched) {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'post_id': widget.postId.toString(),
      'dwell_time': secondsWatched.toString(),
    };
    print("request post time parameter : $data");
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().postDwellTime(data).then((response) async {
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            dwelltimemodel = DwellTimeModel.fromJson(responseData);
          } else if (response.statusCode == 429) {
            setState(() {
              isLikeInProgress = false;
            });
            print("Too many requests");
          } else {
            setState(() {
              isLikeInProgress = false;
            });
            print("Internal Server Error");
          }
        });
      } else {
        setState(() {
          isLikeInProgress = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void PostAsViewedap() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'post_id': widget.postId.toString(),
    };
    print("request view parameter : $data");
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().PostAsViewedApi(data).then((response) async {
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            postasviewedmodel = PostAsViewedModel.fromJson(responseData);
            print("View done");
          } else if (response.statusCode == 429) {
            print("Too many requests");
          } else {
            print("Internal Server Error");
          }
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  // Calculate the scale to ensure video covers the full screen
  // while maintaining aspect ratio (like Reels/Snapchat)
  double _calculateScale(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenAspect = screenSize.width / screenSize.height;
    final double videoAspect = controller.value.aspectRatio;

    // If video is wider than screen, scale by height
    // If video is taller than screen, scale by width
    if (videoAspect > screenAspect) {
      return screenSize.height / (screenSize.width / videoAspect);
    } else {
      return screenSize.width / (screenSize.height * videoAspect);
    }
  }
}
