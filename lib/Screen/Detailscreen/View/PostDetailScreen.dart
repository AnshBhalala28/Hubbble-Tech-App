import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:wavee/comman/SideMenu.dart';
import 'package:wavee/comman/colors.dart';
import 'package:wavee/comman/const.dart';

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Map<String, dynamic>> posts = [
    {
      "userImage":
          "https://images.pexels.com/photos/2747267/pexels-photo-2747267.jpeg?cs=srgb&dl=pexels-sadman-2747267.jpg&fm=jpg",
      "username": "radhi",
      "date": "24 Feb 2025",
      "description": "hello everyone. ",
      "postImage":
          "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D",
      "caption": "Enjoying the sunset! 🌅",
      "comments": [],
    },
    {
      "userImage":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQOP8pXwmUupEhRR_a312SjrPs4xZ292EKdkA&s",
      "username": "fenil",
      "date": "24 Feb 2025",
      "postImage": "https://media.w3.org/2010/05/sintel/trailer.mp4",
      "likes": "200",
      "description": "hello everyone. ",
      "caption": "Weekend vibes! ✨",
    },
    {
      "userImage":
          "https://images.pexels.com/photos/2747267/pexels-photo-2747267.jpeg?cs=srgb&dl=pexels-sadman-2747267.jpg&fm=jpg",
      "username": "radhi",
      "date": "24 Feb 2025",
      "description": "hello everyone. ",
      "discription":
          "A chat can be in text form, or it can include audio or video, which is then called an audio or video chat. ",
      "postImage":
          "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8aW1hZ2V8ZW58MHx8MHx8fDA%3D",
      "caption": "Enjoying the sunset! 🌅",
      "comments": [],
    },
  ];

  // final Map<int, TextEditingController> _commentControllers = {};
  final GlobalKey<ScaffoldState> _scaffoldKey_home = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      key: _scaffoldKey_home,
      body: Container(
        color: AppColors.bgcolor,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: 13.h,
                color: AppColors.bgcolor,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          _scaffoldKey_home.currentState?.openDrawer();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 0.4.h,
                                width: 6.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 0.5.h),
                                height: 0.4.h,
                                width: 8.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              Container(
                                height: 0.4.h,
                                width: 6.w,
                                decoration: BoxDecoration(
                                  color: AppColors.maincolor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "Detail Page",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none_outlined,
                              color: Colors.black87,
                              size: 22.sp,
                            ),
                            onPressed: () {},
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              width: 8.5.w,
                              height: 8.5.h,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://play-lh.googleusercontent.com/vJU6A0cUbsHcEzF_Ach6NsF281DjcseRahBf6KPj7a_keiSowNFGkw2hoLeFX5NtlYAf=w240-h480-rw",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final post = posts[index];
                bool isVideo = post['postImage']!.endsWith('.mp4');

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.2.h,
                    vertical: 2.w,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 0.2.w),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 1.h,
                            horizontal: 3.w,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 6.h,
                                width: 12.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(post["userImage"]!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post["username"]!,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    post["date"]!,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: AppConstants.manrope,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.more_vert,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 0.5.h,
                            horizontal: 3.w,
                          ),
                          child: Text(
                            post["description"]!,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppConstants.manrope,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 1.h,
                            horizontal: 2.5.w,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                                isVideo
                                    ? VideoPlayerWidget(
                                      videoUrl: post["postImage"]!,
                                    )
                                    : CachedNetworkImage(
                                      imageUrl: post["postImage"]!,
                                      placeholder:
                                          (context, url) => SizedBox(
                                            height: 35.h,
                                            width: double.infinity,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) =>
                                              const Icon(Icons.error),
                                      width: double.infinity,
                                      height: 35.h,
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 1.h,
                            horizontal: 3.w,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.favorite_border,
                                        size: 22.sp,
                                        color: Colors.black87,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        "0",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 3.w),
                                  Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.comment,
                                        size: 20.5.sp,
                                        color: Colors.black87,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        "0",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppConstants.manrope,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.share_outlined,
                                size: 20.sp,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: posts.length),
            ),

            // SliverList(
            //   delegate: SliverChildBuilderDelegate(
            //     (context, index) {
            //       final post = posts[index];
            //       _commentControllers[index] = TextEditingController();
            //
            //       return Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            //         child: Container(
            //           decoration: BoxDecoration(
            //             border: Border.all(color: Colors.black12, width: 0.5),
            //             color: Colors.white,
            //             borderRadius: BorderRadius.circular(20),
            //             boxShadow: [
            //               BoxShadow(
            //                   color: Colors.black12,
            //                   blurRadius: 1,
            //                   offset: Offset(0, 1)),
            //             ],
            //           ),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               // 🔹 USER INFO
            //               Padding(
            //                 padding: EdgeInsets.all(10),
            //                 child: Row(
            //                   children: [
            //                     CircleAvatar(
            //                       backgroundImage:
            //                           NetworkImage(post["userImage"]!),
            //                       radius: 25,
            //                     ),
            //                     SizedBox(width: 10),
            //                     Column(
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Text(post["username"]!,
            //                             style: TextStyle(
            //                               fontSize: 16.sp,
            //                               fontWeight: FontWeight.w600,
            //                               fontFamily: AppConstants.manrope,
            //                             )),
            //                         Text(post["date"]!,
            //                             style: TextStyle(
            //                               fontSize: 14.sp,
            //                               color: Colors.grey,
            //                               fontFamily: AppConstants.manrope,
            //                             )),
            //                       ],
            //                     ),
            //                     Spacer(),
            //                     Icon(Icons.more_vert, color: Colors.black87),
            //                   ],
            //                 ),
            //               ),
            //               // 🔹 POST IMAGE
            //               Padding(
            //                 padding: EdgeInsets.all(10),
            //                 child: ClipRRect(
            //                   borderRadius: BorderRadius.circular(10),
            //                   child: CachedNetworkImage(
            //                     imageUrl: post["postImage"]!,
            //                     placeholder: (context, url) => SizedBox(
            //                       height: 200,
            //                       width: double.infinity,
            //                       child: Center(
            //                           child: CircularProgressIndicator()),
            //                     ),
            //                     errorWidget: (context, url, error) =>
            //                         Icon(Icons.error),
            //                     width: double.infinity,
            //                     height: 200,
            //                     fit: BoxFit.cover,
            //                   ),
            //                 ),
            //               ),
            //
            //               Padding(
            //                 padding: EdgeInsets.all(10),
            //                 child: Row(
            //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                   children: [
            //                     Row(
            //                       children: [
            //                         Row(
            //                           children: [
            //                             Icon(Icons.favorite_border,
            //                                 size: 22, color: Colors.black87),
            //                             SizedBox(width: 5),
            //                             Text(
            //                               "0",
            //                               style: TextStyle(
            //                                 fontSize: 14,
            //                                 fontWeight: FontWeight.bold,
            //                                 fontFamily: AppConstants.manrope,
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                         SizedBox(width: 20),
            //                         Row(
            //                           children: [
            //                             GestureDetector(
            //                               onTap: () => _showCommentBottomSheet(
            //                                   context, index),
            //                               child: FaIcon(
            //                                   FontAwesomeIcons.comment,
            //                                   size: 20,
            //                                   color: Colors.black87),
            //                             ),
            //                             SizedBox(width: 5),
            //                             Text(
            //                               posts[index]["comments"]
            //                                   .length
            //                                   .toString(),
            //                               // 🔹 Dynamic Comment Count
            //                               style: TextStyle(
            //                                 fontSize: 14,
            //                                 fontWeight: FontWeight.bold,
            //                                 fontFamily: AppConstants.manrope,
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                       ],
            //                     ),
            //                     Icon(Icons.share_outlined,
            //                         size: 20, color: Colors.black87),
            //                   ],
            //                 ),
            //               ),
            //
            //               if (post["comments"].isNotEmpty)
            //                 if (post["comments"].isNotEmpty)
            //                   Padding(
            //                     padding: EdgeInsets.symmetric(horizontal: 10),
            //                     child: Column(
            //                       mainAxisAlignment: MainAxisAlignment.start,
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Text("Comments :",
            //                             style: TextStyle(
            //                               fontSize: 15,
            //                               fontWeight: FontWeight.bold,
            //                               fontFamily: AppConstants.manrope,
            //                             )),
            //                         ListView.builder(
            //                           padding: EdgeInsets.zero,
            //                           shrinkWrap: true,
            //                           physics: NeverScrollableScrollPhysics(),
            //                           itemCount: post["comments"].length,
            //                           itemBuilder: (context, commentIndex) {
            //                             return Row(
            //                               children: [
            //                                 CircleAvatar(
            //                                   radius: 14,
            //                                   backgroundImage: NetworkImage(
            //                                       post["userImage"]!),
            //                                 ),
            //                                 SizedBox(width: 5),
            //                                 Expanded(
            //                                   child: Container(
            //                                     padding: EdgeInsets.all(10),
            //                                     decoration: BoxDecoration(
            //                                       // color: Colors.grey[200],
            //                                       borderRadius:
            //                                           BorderRadius.circular(10),
            //                                     ),
            //                                     child: Text(post["comments"]
            //                                         [commentIndex]),
            //                                   ),
            //                                 ),
            //                               ],
            //                             );
            //                           },
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //     childCount: posts.length,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // void _showCommentBottomSheet(BuildContext context, int index) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(context).viewInsets.bottom,
  //         ),
  //         child: Container(
  //           padding: EdgeInsets.all(16),
  //           height: 200,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //           ),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Center(
  //                 child: Container(
  //                   width: 40,
  //                   height: 5,
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey[400],
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(height: 10),
  //               Text(
  //                 "Add a Comment",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   fontFamily: AppConstants.manrope,
  //                 ),
  //               ),
  //               SizedBox(height: 10),
  //               Container(
  //                 height: 8.h,
  //                 child: TextField(
  //                   controller: _commentControllers[index],
  //                   decoration: InputDecoration(
  //                     hintText: "Type your comment...",
  //                     hintStyle: TextStyle(
  //                       color: Colors.grey,
  //                       fontFamily: AppConstants.manrope,
  //                     ),
  //                     filled: true,
  //                     fillColor: Colors.grey[100],
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(15),
  //                       borderSide: BorderSide.none,
  //                     ),
  //                   ),
  //                   textInputAction: TextInputAction.done,
  //                 ),
  //               ),
  //               SizedBox(height: 10),
  //               Align(
  //                 alignment: Alignment.center,
  //                 child: InkWell(
  //                   onTap: () {
  //                     if (_commentControllers[index]!.text.isNotEmpty) {
  //                       setState(() {
  //                         posts[index]["comments"]
  //                             .add(_commentControllers[index]!.text);
  //                         _commentControllers[index]!.clear();
  //                       });
  //                       Navigator.pop(context);
  //                     }
  //                   },
  //                   child: Container(
  //                     height: 6.h,
  //                     width: 30.w,
  //                     decoration: BoxDecoration(
  //                         color: Colors.grey.shade300,
  //                         borderRadius: BorderRadius.all(Radius.circular(10))),
  //                     child: Center(
  //                         child: Text(
  //                       "Post Comment",
  //                     )),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool isPlaying = false;
  bool showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = _controller.value.isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showControls = !showControls;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
              : const Center(child: CircularProgressIndicator()),
          if (showControls)
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
              onPressed: _togglePlayPause,
            ),
        ],
      ),
    );
  }
}
