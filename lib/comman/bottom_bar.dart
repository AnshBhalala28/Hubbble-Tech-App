import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Add%20to%20Cart/view/add_to_cart_view.dart';
import 'package:wavee/Screen/Chatscreen/View/chatscreen.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/view/community_screen.dart';
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
            color: Colors.white,
          ),
          height: Platform.isAndroid ? 10.h : 12.h,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                svgIconPath: AppConstants.home,
                label: "Home",
                index: 1,
                onTap:
                    () => Get.offAll(() => HomePage(selected: 1, userName: "")),
              ),
              _buildNavItem(
                svgIconPath: AppConstants.community,
                label: "Community",
                index: 2,
                onTap: () => Get.offAll(() => CommunityScreen(selected: 2)),
              ),
              _buildNavItem(
                svgIconPath: AppConstants.chat1,
                label: "Chat",
                index: 3,
                onTap: () => Get.offAll(() => ChatScreen(selected: 3)),
              ),
              _buildNavItem(
                svgIconPath: AppConstants.cart,
                label: "My Cart",
                index: 4,
                onTap:
                    () => Get.offAll(
                      () => AddToCartView(selected: 4, fromBottomBar: true),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required String svgIconPath,
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
          SvgPicture.asset(
            svgIconPath,
            height: 22.sp,
            width: 22.sp,
            color: widget.selected == index ? AppColors.maincolor : Colors.grey,
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
