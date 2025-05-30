// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoWidget extends StatefulWidget {
//   final String videoUrl;
//
//   VideoWidget({required this.videoUrl});
//
//   @override
//   _VideoWidgetState createState() => _VideoWidgetState();
// }
//
// class _VideoWidgetState extends State<VideoWidget> {
//   late VideoPlayerController _controller;
//   ChewieController? _chewieController;
//   bool _isInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {
//           _isInitialized = true;
//         });
//         _controller.setLooping(false); // Remove infinite looping
//       });
//
//     _chewieController = ChewieController(
//       videoPlayerController: _controller,
//       autoPlay: false,
//       looping: false, // No infinite looping
//       showControls: false, // Hide controls initially
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
//
//   /// Opens full-screen player when video is tapped (in portrait mode)
//   void _openFullScreen() async {
//     if (!_isInitialized) return; // Prevents opening before initialization
//
//     _controller.pause(); // Pause current video before opening full screen
//
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           backgroundColor: Colors.black,
//           body: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Center(
//                   child: AspectRatio(
//                     aspectRatio: 9 / 16,
//                     // Force vertical full-screen aspect ratio
//                     child: Chewie(
//                       controller: ChewieController(
//                         videoPlayerController: _controller,
//                         autoPlay: true,
//                         // Start playing in full-screen mode
//                         looping: false,
//                         // Do not loop infinitely
//                         allowPlaybackSpeedChanging: false,
//                         allowFullScreen: false,
//                         // Already full-screen
//                         allowMuting: true,
//                         showControls:
//                             true, // Show playback controls in full screen
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 40.0),
//                 child: IconButton(
//                   icon: Icon(Icons.close, color: Colors.white, size: 30),
//                   onPressed: () {
//                     _controller.pause(); // Stop video when closing full screen
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//
//     _controller.pause(); // Ensure video is stopped when returning
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _openFullScreen, // Open full screen on tap
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           _isInitialized
//               ? ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: SizedBox.expand(
//                     // Ensure video fills container
//                     child: FittedBox(
//                       fit: BoxFit.cover, // Makes video behave like an image
//                       child: SizedBox(
//                         width: _controller.value.size.width,
//                         height: _controller.value.size.height,
//                         child: VideoPlayer(_controller),
//                       ),
//                     ),
//                   ),
//                 )
//               : Center(child: CircularProgressIndicator()),
//
//           // Play Button Overlay
//           Positioned(
//             child: Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
// }
// VideoWidget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../Screen/Community Screen/Community Screen/view/FullScreenVideoPlayer.dart';

class VideoWidget extends StatefulWidget {
  final String videoUrl;
  final bool play;
  final int postId; // Added postId parameter

  VideoWidget({
    required this.videoUrl,
    this.play = false,
    required this.postId, // Make postId required
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
        // Pass the postId to FullScreenVideoPlayer
        Get.to(() => FullScreenVideoPlayer(
              videoUrl: widget.videoUrl,
              postId: widget.postId,
            ));
      },
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
