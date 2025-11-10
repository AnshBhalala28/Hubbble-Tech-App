import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/const.dart';
import '../../../Utils/errorDialog.dart';
import '../Provider/communityProvider.dart';
import '../modal/DwellTimeModel.dart';
import '../modal/PostAsViewedModel.dart';
import '../modal/postlikemodel.dart';

class FullScreenMediaView extends StatefulWidget {
  final List<dynamic> posts;
  final int postId;
  final int initialIndex; // 👈 new parameter

  const FullScreenMediaView({
    super.key,
    required this.posts,
    required this.postId,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  bool isLiked = false;
  bool isLikeInProgress = false;
  DateTime? startTime;
  DateTime? endTime;

  late PageController _pageController;
  int currentIndex = 0;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _pageController = PageController(initialPage: widget.initialIndex); // 👈
    PostAsViewedap();
    _loadLikeStatus();
    _initializeCurrentMedia();
  }

  @override
  void dispose() {
    endTime = DateTime.now();
    final dwellDuration = endTime!.difference(startTime!);
    final secondsWatched = dwellDuration.inSeconds;

    if (secondsWatched > 3) {
      imagedwelltimeapi(secondsWatched);
    }

    _disposeVideo();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLikeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'image_like_${widget.postId}_$userId';
    setState(() {
      isLiked = prefs.getBool(key) ?? false;
    });
  }

  Future<void> _saveLikeStatus(bool liked) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'image_like_${widget.postId}_$userId';
    await prefs.setBool(key, liked);
  }

  void handleLikeToggle() {
    if (isLikeInProgress) return;
    setState(() => isLikeInProgress = true);
    postslikeap();
  }

  void _disposeVideo() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  void _initializeCurrentMedia() async {
    _disposeVideo();
    final currentPost = widget.posts[currentIndex];

    if (currentPost['type'] == 'video') {
      final videoUrl = currentPost['file'];
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: false,
        allowMuting: true,
        showControls: true,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.posts.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
              _initializeCurrentMedia();
            },
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              final isVideo = post['type'] == 'video';
              final fileUrl = post['file'];

              if (isVideo) {
                return _chewieController != null &&
                        _videoController != null &&
                        _videoController!.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
              } else {
                return CachedNetworkImage(
                  imageUrl: fileUrl,
                  fit: BoxFit.contain,
                  width: 100.w,
                  height: 100.h,
                  placeholder:
                      (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (_, __, ___) =>
                          const Icon(Icons.error, color: Colors.white),
                );
              }
            },
          ),

          // 🔹 Close button
          Positioned(
            top: 7.h,
            right: 3.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                iconSize: 24,
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // 🔹 Like button
          Positioned(
            bottom: 5.h,
            right: 5.w,
            child: GestureDetector(
              onTap: isLikeInProgress ? null : handleLikeToggle,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // 🔹 Page indicator
          if (widget.posts.length > 1)
            Positioned(
              bottom: 5.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.posts.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentIndex == index ? 10 : 6,
                    height: currentIndex == index ? 10 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          currentIndex == index
                              ? Colors.white
                              : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🔹 API Calls

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
          } else {
            setState(() => isLikeInProgress = false);
          }
        });
      } else {
        setState(() => isLikeInProgress = false);
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void imagedwelltimeapi(int secondsWatched) {
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
          }
        });
      } else {
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
          }
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}
