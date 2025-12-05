import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:video_player/video_player.dart';

import '../../../Utils/checkInternetConnection.dart';
import '../../../Utils/const.dart';
import '../../../Utils/errorDialog.dart';
import '../../messageScreen/View/messageScreen.dart';
import '../Provider/communityProvider.dart';
import '../modal/StroyModel.dart';
import '../modal/postlikemodel.dart';

class StoryViewerScreen extends StatefulWidget {
  final int userId;

  const StoryViewerScreen({super.key, required this.userId});

  @override
  _StoryViewerScreenState createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  VideoPlayerController? _videoController;
  bool isLoading = true;
  late AnimationController _animationController;
  bool isPaused = false;
  List<FeaturedPosts> stories = [];

  String appLat = '';
  String appLon = '';
  String? city;

  bool isLiked = false;
  bool isLikeInProgress = false;

  final List<VideoPlayerController?> _preloadedVideoControllers = [];
  final List<bool> _preloadedImages = [];

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isPaused) {}
    });

    _fetchUserStories(widget.userId.toString());
    _loadLikeStatus(currentIndex);
  }

  Future<void> _loadLikeStatus(int storyIndex) async {
    if (stroymodel?.data?.featuredPosts == null ||
        storyIndex >= (stroymodel?.data?.featuredPosts?.length ?? 0)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final storyId =
        stroymodel?.data?.featuredPosts?[storyIndex].id.toString() ?? '';
    final key = 'image_like_${storyId}_$userId';

    setState(() {
      isLiked = prefs.getBool(key) ?? false;
    });
  }

  Future<void> _saveLikeStatus(bool liked) async {
    if (stroymodel?.data?.featuredPosts == null ||
        currentIndex >= (stroymodel?.data?.featuredPosts?.length ?? 0)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final storyId =
        stroymodel?.data?.featuredPosts?[currentIndex].id.toString() ?? '';
    final key = 'image_like_${storyId}_$userId';

    await prefs.setBool(key, liked);
  }

  void handleLikeToggle() {
    if (isLikeInProgress) return;

    setState(() {
      isLikeInProgress = true;
    });

    postslikeap();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      appLat = position.latitude.toString();
      appLon = position.longitude.toString();
      getCityName(
        double.parse(appLat.toString()),
        double.parse(appLon.toString()),
      );
    });
  }

  Future<void> getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          city = placemarks[0].locality;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animationController.dispose();

    for (var controller in _preloadedVideoControllers) {
      controller?.dispose();
    }

    super.dispose();
  }

  final StoryController _storyController = StoryController();

  @override
  Widget build(BuildContext context) {
    if (isLoading && stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No Stories Available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final storyItems =
        stories.map((story) {
          if (story.type == "image") {
            return StoryItem.pageImage(
              url: story.file!,
              controller: _storyController,
              duration: const Duration(seconds: 5),
              imageFit: BoxFit.cover,
            );
          } else {
            return StoryItem.pageVideo(
              story.file!,
              controller: _storyController,
              duration: const Duration(seconds: 10),
            );
          }
        }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StoryView(
            storyItems: storyItems,
            controller: _storyController,
            onComplete: () {
              Get.back();
            },
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Get.back();
              }
            },
            repeat: false,
          ),
          Positioned(
            top: 7.h,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
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
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Get.to(
                  MessageScreen(
                    type: "business",
                    chatName: stroymodel?.data?.owner?.name ?? "N/A",
                    conciergeID: (stroymodel?.data?.owner?.userId).toString(),
                    image: stroymodel?.data?.owner?.logo ?? "",
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.conversation_bubble,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUserStories(String id) async {
    if (!await checkInternet()) {
      buildErrorDialog(context, 'Error', 'Internet Required');
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final loginId = (loginModel?.data?.user?.id).toString();
      final response = await CommunityProvider().storyViewApi(loginId, id);

      if (response.statusCode == 200) {
        stroymodel = StroyModel.fromJson(response.data);

        final posts = stroymodel?.data?.featuredPosts ?? [];
        setState(() {
          stories = posts;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void postslikeap() {
    if (stroymodel?.data?.featuredPosts == null ||
        currentIndex >= (stroymodel?.data?.featuredPosts?.length ?? 0)) {
      setState(() => isLikeInProgress = false);
      return;
    }

    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'type': 'post',
      'post_offer_promo_id':
          (stroymodel?.data?.featuredPosts?[currentIndex].id).toString(),
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
          } else if (response.statusCode == 429) {
            setState(() => isLikeInProgress = false);
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
}

class StoryProgressIndicator extends StatefulWidget {
  final bool isActive;
  final bool isPaused;
  final bool isCompleted;
  final Duration duration;
  final AnimationController? animationController;
  final VideoPlayerController? videoController;

  const StoryProgressIndicator({
    super.key,
    required this.isActive,
    required this.isPaused,
    required this.isCompleted,
    required this.duration,
    this.animationController,
    this.videoController,
  });

  @override
  State<StoryProgressIndicator> createState() => _StoryProgressIndicatorState();
}

class _StoryProgressIndicatorState extends State<StoryProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    if (widget.isCompleted) {
      return Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.5),
        ),
      );
    }

    if (widget.isActive) {
      return AnimatedBuilder(
        animation:
            widget.videoController != null
                ? widget.videoController!
                : widget.animationController!,
        builder: (context, child) {
          double progress = 0.0;

          if (widget.videoController != null &&
              widget.videoController!.value.isInitialized) {
            progress =
                widget.videoController!.value.position.inMilliseconds /
                widget.videoController!.value.duration.inMilliseconds;
          } else {
            progress = widget.animationController!.value;
          }

          return Stack(
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
