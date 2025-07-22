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
    startTime = DateTime.now();
    PostAsViewedap();

    _loadLikeStatus();
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

    setState(() {
      isLikeInProgress = true;
    });

    postslikeap();
  }

  @override
  void dispose() {
    endTime = DateTime.now();
    final dwellDuration = endTime!.difference(startTime!);
    final secondsWatched = dwellDuration.inSeconds;

    if (secondsWatched > 3) {
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
          Container(
            width: 100.w,
            height: 100.h,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.contain,
              placeholder:
                  (_, __) => const Center(child: CircularProgressIndicator()),
              errorWidget:
                  (_, __, ___) => const Icon(Icons.error, color: Colors.white),
            ),
          ),
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

            print(
              isLiked
                  ? "Image liked successfully"
                  : "Image unliked successfully",
            );
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
}
