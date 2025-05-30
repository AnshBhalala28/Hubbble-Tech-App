import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
import 'package:wavee/Screen/Message_board/View/messageboard.dart';
import 'package:wavee/Screen/Oredrscreen/View/order_screen_view.dart';
import 'package:wavee/comman/const.dart';

import '../Screen/HomeNewPage/View/homenewpage.dart';
import 'colors.dart';

class Bottom_bar extends StatefulWidget {
  int? selected;

  Bottom_bar({super.key, this.selected});

  @override
  State<Bottom_bar> createState() => _Bottom_barState();
}

class _Bottom_barState extends State<Bottom_bar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white, // 🔹 Changed to White
          ),
          height: Platform.isAndroid ? 10.h : 12.h,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: CupertinoIcons.home,
                label: "Home",
                index: 1,
                onTap:
                    () => Get.offAll(
                      () => HomeNewPage(selected: 1, userName: ""),
                    ),
              ),
              _buildNavItem(
                icon: CupertinoIcons.chat_bubble_2,
                label: "Chat",
                index: 2,
                onTap: () => Get.offAll(() => ChatScreen(selected: 2)),
              ),
              _buildNavItem(
                icon: CupertinoIcons.location_solid,
                label: "Community",
                index: 3,
                onTap: () => Get.offAll(() => CommunityScreen(selected: 3)),
              ),
              _buildNavItem(
                icon: CupertinoIcons.conversation_bubble,
                label: "Board",
                index: 4,
                onTap: () => Get.offAll(() => Messageboard(selected: 4)),
              ),
              _buildNavItem(
                icon: Icons.shopping_cart,
                label: "Orders",
                index: 5,
                onTap: () => Get.offAll(() => Order_Screen(selected: 5)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.selected != index) {
          setState(() {
            widget.selected = index;
          });
          onTap();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22.sp,
            color:
                widget.selected == index
                    ? AppColors.maincolor
                    : Colors.grey, // 🔹 Icon Color Change
          ),
          SizedBox(
            width: 19.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    widget.selected == index
                        ? AppColors.maincolor
                        : Colors.grey,
                // 🔹 Text Color Change
                fontSize: 14.5.sp,
                fontFamily: AppConstants.manrope,
              ),
            ),
          ),
          SizedBox(height: 0.4.h),
          Container(
            height: 0.4.h,
            width: 11.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color:
                  widget.selected == index
                      ? AppColors.maincolor
                      : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
