import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../comman/const.dart';

class StoryScreen extends StatelessWidget {
  final List<String> storyImages;
  final List<String> userNames;
  final List<String> userProfileImages;
  final int initialIndex;

  const StoryScreen({
    Key? key,
    required this.storyImages,
    required this.userNames,
    required this.userProfileImages,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: storyImages.length,
            controller: pageController,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Center(
                    child: Image.network(
                      storyImages[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.error, color: Colors.red, size: 50),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: NetworkImage(
                            userProfileImages[index],
                          ),
                          onBackgroundImageError:
                              (_, __) =>
                                  Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text(
                          userNames[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: AppConstants.manrope,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // Positioned(
          //   top: 8.h,
          //   right: 8.w,
          //   child: IconButton(
          //     icon: Icon(Icons.close, color: Colors.white, size: 30),
          //     onPressed: () => Get.back(),
          //   ),
          // ),
        ],
      ),
    );
  }
}
