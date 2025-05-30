import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../../comman/check_inernet_connecty.dart';
import '../../../../comman/const.dart';
import '../../../../comman/error_dialog.dart';
import '../../../Message_screen/View/messageScreen.dart';
import '../Model/StroyModel.dart';
import '../Model/postlikemodel.dart';
import '../Provider/community_provider.dart';

class StoryViewerScreen extends StatefulWidget {
  final int userId;

  const StoryViewerScreen({Key? key, required this.userId}) : super(key: key);

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

  // For preloading
  List<VideoPlayerController?> _preloadedVideoControllers = [];
  List<bool> _preloadedImages = [];

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();

    // ઇંડિકેટર માટે એનિમેશન કંટ્રોલર
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isPaused) {
        _nextStory();
      }
    });

    print("getid: ${widget.userId.toString()}");

    _fetchUserStories(widget.userId.toString());
    _loadLikeStatus(currentIndex);
  }

  // Load like status from SharedPreferences
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

  // Save like status to SharedPreferences
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

  // Pre-load stories for smoother experience
  void _preloadStories() {
    _preloadedVideoControllers = List.filled(stories.length, null);
    _preloadedImages = List.filled(stories.length, false);

    // બધી સ્ટોરીઝ પ્રી-લોડ કરવાનું શરૂ કરો
    for (int i = 0; i < stories.length; i++) {
      if (stories[i].type == "video" && stories[i].file != null) {
        _preloadedVideoControllers[i] =
            VideoPlayerController.network(stories[i].file!)
              ..initialize().then((_) {
                print("Preloaded video $i");
              });
      } else if (stories[i].type == "image" && stories[i].file != null) {
        precacheImage(NetworkImage(stories[i].file!), context).then((_) {
          _preloadedImages[i] = true;
          print("Preloaded image $i");
        });
      }
    }
  }

  void _loadStory(int index) async {
    if (index < 0 || index >= stories.length) return;

    setState(() {
      isLoading = true;
      isPaused = false;
      currentIndex = index;
    });

    if (_videoController != null) {
      await _videoController!.pause();
      await _videoController!.dispose();
      _videoController = null;
    }

    _animationController.reset();

    final story = stories[index];
    _loadLikeStatus(index);

    if (story.type == "video" && story.file != null) {
      // Check if we have a preloaded controller
      if (_preloadedVideoControllers.length > index &&
          _preloadedVideoControllers[index] != null) {
        _videoController = _preloadedVideoControllers[index];
        _preloadedVideoControllers[index] = null; // Clear from preloaded list

        setState(() {
          isLoading = false;
        });

        _videoController!.seekTo(Duration.zero);
        _videoController!.play();

        _videoController!.addListener(() {
          if (_videoController!.value.position >=
              _videoController!.value.duration) {
            _nextStory();
          }
        });
      } else {
        // Fall back to normal loading
        _videoController = VideoPlayerController.network(story.file!)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
              _videoController?.play();
              _videoController?.addListener(() {
                if (_videoController!.value.position >=
                    _videoController!.value.duration) {
                  _nextStory();
                }
              });
            }
          });
      }
    } else {
      // Image story
      bool isPreloaded =
          _preloadedImages.length > index && _preloadedImages[index];

      if (isPreloaded) {
        setState(() {
          isLoading = false;
        });
        _animationController.forward(from: 0);
      } else if (story.file != null) {
        precacheImage(NetworkImage(story.file!), context).then((_) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            _animationController.forward(from: 0);
          }
        }).catchError((error) {
          print("Error caching image: $error");
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            _animationController.forward(from: 0);
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _animationController.forward(from: 0);
      }
    }

    // Preload next story
    _preloadNextStory(index);
  }

  void _preloadNextStory(int currentIndex) {
    if (currentIndex + 1 >= stories.length) return;

    final nextStory = stories[currentIndex + 1];

    if (nextStory.type == "video" &&
        nextStory.file != null &&
        (_preloadedVideoControllers.length <= currentIndex + 1 ||
            _preloadedVideoControllers[currentIndex + 1] == null)) {
      _preloadedVideoControllers[currentIndex + 1] =
          VideoPlayerController.network(nextStory.file!)
            ..initialize().then((_) {
              print("Preloaded next video ${currentIndex + 1}");
            });
    } else if (nextStory.type == "image" &&
        nextStory.file != null &&
        (_preloadedImages.length <= currentIndex + 1 ||
            !_preloadedImages[currentIndex + 1])) {
      precacheImage(NetworkImage(nextStory.file!), context).then((_) {
        _preloadedImages[currentIndex + 1] = true;
        print("Preloaded next image ${currentIndex + 1}");
      });
    }
  }

  void _nextStory() {
    if (currentIndex < stories.length - 1) {
      _loadStory(currentIndex + 1);
    } else {
      Get.back();
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      _loadStory(currentIndex - 1);
    }
  }

  void _pauseStory() {
    if (_videoController != null && _videoController!.value.isPlaying) {
      _videoController?.pause();
    }
    _animationController.stop();
    setState(() {
      isPaused = true;
    });
  }

  void _resumeStory() {
    if (_videoController != null && !_videoController!.value.isPlaying) {
      _videoController?.play();
    }
    _animationController.forward();
    setState(() {
      isPaused = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        print("Location services are disabled.");
        isLoading = false; // Stop loader if location is disabled
      });
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          print("Location permission denied.");
          isLoading = false; // Stop loader if permission denied
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        print("Location permissions are permanently denied.");
        isLoading = false; // Stop loader if permanently denied
      });
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      appLat = position.latitude.toString();
      appLon = position.longitude.toString();
      getCityName(
          double.parse(appLat.toString()), double.parse(appLon.toString()));
      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    });
  }

  Future<void> getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          city = placemarks[0].locality;
        });
        print("City Name: $city");
      }
    } catch (e) {
      print("Error getting city name: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animationController.dispose();

    // Dispose all preloaded controllers
    for (var controller in _preloadedVideoControllers) {
      controller?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text('કોઈ સ્ટોરી ઉપલબ્ધ નથી',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final story = stories[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        child: Stack(
          children: [
            // Story content
            Center(
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : story.type == "image"
                      ? Image.network(
                          story.file!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error,
                                  color: Colors.white, size: 50),
                            );
                          },
                        )
                      : _videoController != null &&
                              _videoController!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: VideoPlayer(_videoController!),
                            )
                          : const CircularProgressIndicator(
                              color: Colors.white),
            ),

            // Left/Right tap areas for navigation
            Row(
              children: [
                // Left area - previous story
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _previousStory,
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Middle area - pause/resume
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    onTapDown: (_) => _pauseStory(),
                    onTapUp: (_) => _resumeStory(),
                    onLongPressStart: (_) => _pauseStory(),
                    onLongPressEnd: (_) => _resumeStory(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Right area - next story
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _nextStory,
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),

            // Instagram-style story indicators at top
            Positioned(
              top: 44,
              left: 8,
              right: 8,
              child: Row(
                children: stories.asMap().entries.map((entry) {
                  int index = entry.key;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: StoryProgressIndicator(
                        isActive: index == currentIndex,
                        isPaused: isPaused,
                        isCompleted: index < currentIndex,
                        duration:
                            story.type == "video" && _videoController != null
                                ? _videoController!.value.duration
                                : const Duration(seconds: 5),
                        animationController:
                            index == currentIndex ? _animationController : null,
                        videoController:
                            index == currentIndex && story.type == "video"
                                ? _videoController
                                : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Close button
            Positioned(
              top: 6.5.h,
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

            // Like button
            Positioned(
              bottom: 12.h,
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

            // Message button
            Positioned(
              bottom: 5.h,
              right: 5.w,
              child: GestureDetector(
                onTap: () {
                  print(
                      'Hello Id ${busnessviewmodal?.data?.business?.user?.id}');
                  print('Mine Id ${stroymodel?.data?.owner?.userId}');
                  print('Image is ${busnessviewmodal?.data?.business?.logo}');
                  Get.to(MessageScreen(
                    type: "business",
                    chatName: stroymodel?.data?.owner?.name ?? "N/A",
                    conciergeID: (stroymodel?.data?.owner?.userId).toString(),
                    image: stroymodel?.data?.owner?.logo ?? "",
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.conversation_bubble,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchUserStories(String id) async {
    debugPrint("API calling start");
    debugPrint("Fetching stories for user ID: $id");

    if (!await checkInternet()) {
      buildErrorDialog(context, 'Error', 'Internet Required');
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      // API call
      final loginId = (loginModel?.data?.user?.id).toString();
      debugPrint("Using login ID: $loginId and target ID: $id");

      final response = await CommunityProvider().stroyapi(loginId, id);
      debugPrint("API response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Success response - Log the entire response for debugging
        final responseBody = response.body;
        debugPrint("API Response body: $responseBody");

        final data = json.decode(responseBody);
        stroymodel = StroyModel.fromJson(data);

        if (stroymodel == null) {
          debugPrint("Failed to parse StroyModel from response");
          setState(() => isLoading = false);
          return;
        }

        debugPrint("Parsed status: ${stroymodel?.status}");

        // Deep check if data is available
        if (stroymodel?.status == 200 && stroymodel?.data != null) {
          if (stroymodel!.data!.featuredPosts!.isEmpty) {
            debugPrint("API returned empty data array");
            setState(() => isLoading = false);
            return;
          }

          // Set stories and load first one
          setState(() {
            stories = stroymodel!.data!.featuredPosts!;
            debugPrint("Stories loaded: ${stories.length}");
          });

          // Preload stories for smooth experience
          _preloadStories();

          // Load the first story
          _loadStory(0);
        } else {
          debugPrint("API returned success but invalid data structure");
          setState(() => isLoading = false);
        }
      } else {
        // Non‑200 responses
        debugPrint("API error ${response.statusCode}: ${response.body}");

        try {
          final data = json.decode(response.body);
          stroymodel = StroyModel.fromJson(data);
          final errMsg =
              stroymodel?.message ?? 'Server returned ${response.statusCode}';
          EasyLoading.showError(errMsg);
        } catch (parseError) {
          debugPrint("Failed to parse error response: $parseError");
          EasyLoading.showError('Server returned ${response.statusCode}');
        }

        setState(() => isLoading = false);
      }
    } catch (e, st) {
      // Any unexpected error
      debugPrint('Exception in _fetchUserStories → $e\n$st');
      final errMsg = 'Wrong try again.';
      EasyLoading.showError(errMsg);
      setState(() => isLoading = false);
    }
  }

  // void postslikeap() {
  //   final Map<String, String> data = {
  //     'user_id': (loginModel?.data?.user?.id).toString(),
  //     'type': 'post',
  //     'post_offer_promo_id': (stroymodel?.data?.featuredPosts?[currentIndex].id).toString(),
  //   };
  //   print("Image Like Request: $data");
  //
  //   checkInternet().then((internet) async {
  //     if (internet) {
  //       CommunityProvider().postlikeapi(data).then((response) async {
  //         if (response.statusCode == 200) {
  //           var responseData = json.decode(response.body);
  //           postlikemodel = PostLikeModel.fromJson(responseData);
  //
  //           setState(() {
  //             isLiked = !isLiked;
  //             isLikeInProgress = false;
  //           });
  //
  //           // Save the updated like status to SharedPreferences
  //           _saveLikeStatus(isLiked);
  //
  //           print(isLiked
  //               ? "Image liked successfully"
  //               : "Image unliked successfully");
  //         } else if (response.statusCode == 429) {
  //           setState(() => isLikeInProgress = false);
  //           print("Too many requests");
  //         } else {
  //           setState(() => isLikeInProgress = false);
  //           print("Internal Server Error");
  //         }
  //       });
  //     } else {
  //       setState(() => isLikeInProgress = false);
  //       buildErrorDialog(context, 'Error', "Internet Required");
  //     }
  //   });
  // }

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
    print("Image Like Request: $data");

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().postlikeapi(data).then((response) async {
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            postlikemodel = PostLikeModel.fromJson(responseData);

            setState(() {
              isLiked = !isLiked;
              isLikeInProgress = false;
            });

            // Save the updated like status to SharedPreferences for the current story only
            _saveLikeStatus(isLiked);

            print(isLiked
                ? "Image liked successfully"
                : "Image unliked successfully");
          } else if (response.statusCode == 429) {
            setState(() => isLikeInProgress = false);
            print("Too many requests");
          } else {
            setState(() => isLikeInProgress = false);
            print("Internal Server Error");
          }
        });
      } else {
        setState(() => isLikeInProgress = false);
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }
}

// Instagram જેવી સ્ટોરી indicator ક્લાસ
class StoryProgressIndicator extends StatefulWidget {
  final bool isActive;
  final bool isPaused;
  final bool isCompleted;
  final Duration duration;
  final AnimationController? animationController;
  final VideoPlayerController? videoController;

  const StoryProgressIndicator({
    Key? key,
    required this.isActive,
    required this.isPaused,
    required this.isCompleted,
    required this.duration,
    this.animationController,
    this.videoController,
  }) : super(key: key);

  @override
  State<StoryProgressIndicator> createState() => _StoryProgressIndicatorState();
}

class _StoryProgressIndicatorState extends State<StoryProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    // જો પૂર્ણ થયેલ સ્ટોરી હોય તો 100% ફિલ કરો
    if (widget.isCompleted) {
      return Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.5),
        ),
      );
    }

    // જો એક્ટિવ સ્ટોરી હોય તો પ્રોગ્રેસ દેખાડો
    if (widget.isActive) {
      return AnimatedBuilder(
        animation: widget.videoController != null
            ? widget.videoController!
            : widget.animationController!,
        builder: (context, child) {
          double progress = 0.0;

          if (widget.videoController != null &&
              widget.videoController!.value.isInitialized) {
            progress = widget.videoController!.value.position.inMilliseconds /
                widget.videoController!.value.duration.inMilliseconds;
          } else {
            progress = widget.animationController!.value;
          }

          return Stack(
            children: [
              // Background bar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              // Progress bar
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

    // જો પેન્ડિંગ (હજુ નહીં જોયેલી) સ્ટોરી હોય તો ખાલી બાર દેખાડો
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
