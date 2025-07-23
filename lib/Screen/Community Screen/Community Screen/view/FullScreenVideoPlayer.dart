import 'dart:async';

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

    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'post_like_${widget.postId}_$userId';
    setState(() {
      isLiked = prefs.getBool(key) ?? false;
    });
  }

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

    endTime = DateTime.now();
    final dwellDuration = endTime!.difference(startTime!);
    final secondsWatched = dwellDuration.inSeconds;

    if (secondsWatched > 3) {
      videodwelltimeapi(secondsWatched);
    }

    super.dispose();
  }

  void _togglePlayPauseControl() {
    setState(() {
      isPlayPauseVisible = true;
    });

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

  void handleLikeToggle() {
    if (isLikeInProgress) return;

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
                  child:
                      controller.value.aspectRatio > 0
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

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().postLikeApi(data).then((response) async {
          if (response.statusCode == 200) {
            postlikemodel = PostLikeModel.fromJson(response.data);

            setState(() {
              isLiked = !isLiked;
              isLikeInProgress = false;
            });

            _saveLikeStatus(isLiked);

            if (isLiked) {
            } else {}
          } else if (response.statusCode == 429) {
            setState(() {
              isLikeInProgress = false;
            });
          } else {
            setState(() {
              isLikeInProgress = false;
            });
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

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().recoedDwellApi(data).then((response) async {
          if (response.statusCode == 200) {
            dwelltimemodel = DwellTimeModel.fromJson(response.data);
          } else if (response.statusCode == 429) {
            setState(() {
              isLikeInProgress = false;
            });
          } else {
            setState(() {
              isLikeInProgress = false;
            });
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

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().postMarkViewApi(data).then((response) async {
          if (response.statusCode == 200) {
            postasviewedmodel = PostAsViewedModel.fromJson(response.data);
          } else if (response.statusCode == 429) {
          } else {}
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  double _calculateScale(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenAspect = screenSize.width / screenSize.height;
    final double videoAspect = controller.value.aspectRatio;

    if (videoAspect > screenAspect) {
      return screenSize.height / (screenSize.width / videoAspect);
    } else {
      return screenSize.width / (screenSize.height * videoAspect);
    }
  }
}
