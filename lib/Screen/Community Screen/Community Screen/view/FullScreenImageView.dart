import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../../comman/check_inernet_connecty.dart';
import '../../../../comman/const.dart';
import '../../../../comman/error_dialog.dart';
import '../Model/DwellTimeModel.dart';
import '../Model/PostAsViewedModel.dart';
import '../Model/postlikemodel.dart';
import '../Provider/community_provider.dart';

class FullScreenImageView extends StatefulWidget {
  final String imageUrl;
  final int postId;

  const FullScreenImageView({
    super.key,
    required this.imageUrl,
    required this.postId,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  bool isLiked = false;
  bool isLikeInProgress = false;
  DateTime? startTime;
  DateTime? endTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now(); // Start tracking time here
    PostAsViewedap();
    // Load like status from SharedPreferences
    _loadLikeStatus();
  }

  // Load like status from SharedPreferences
  Future<void> _loadLikeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'image_like_${widget.postId}_$userId';
    setState(() {
      isLiked = prefs.getBool(key) ?? false;
    });
  }

  // Save like status to SharedPreferences
  Future<void> _saveLikeStatus(bool liked) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = loginModel?.data?.user?.id.toString() ?? '';
    final key = 'image_like_${widget.postId}_$userId';
    await prefs.setBool(key, liked);
  }

  void handleLikeToggle() {
    if (isLikeInProgress) return;

    setState(() {
      isLikeInProgress = true;
    });

    postslikeap();
  }

  @override
  void dispose() {
    //  Dwell time calculation before screen dispose
    endTime = DateTime.now();
    final dwellDuration = endTime!.difference(startTime!);
    final secondsWatched = dwellDuration.inSeconds;

    if (secondsWatched > 3) {
      // Optional: Filter out quick exits
      imagedwelltimeapi(secondsWatched);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen Centered Image
          Container(
            width: 100.w,
            height: 100.h,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.error, color: Colors.white),
            ),
          ),

          // Close Button - Top Right with Gray Circle Background
          Positioned(
            top: 3.h,
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

          // Like Button - Bottom Left with Gray Circle Background
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
        ],
      ),
    );
  }

  void postslikeap() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'type': 'post',
      'post_offer_promo_id': widget.postId.toString(),
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

            // Save the updated like status to SharedPreferences
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

  void imagedwelltimeapi(int secondsWatched) {
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
}
