import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../Ui/Chatscreen/View/chatScreen.dart';
import '../Ui/CommunityScreen/view/communityScreen.dart';
import '../Ui/HomeScreen/View/homePage.dart';
import '../Ui/cartScreen/view/cartViewScreen.dart';
import 'colors.dart';
import 'const.dart';

class BottomBar extends StatefulWidget {
  final int? selected;
  final int? chatCount;
  final VoidCallback? onChatCountUpdate;

  const BottomBar({
    super.key,
    this.selected,
    this.chatCount = 0,
    this.onChatCountUpdate,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _chatCount = 0;

  @override
  void initState() {
    super.initState();
    _chatCount = widget.chatCount ?? 0;
  }

  @override
  void didUpdateWidget(covariant BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chatCount != oldWidget.chatCount) {
      setState(() {
        _chatCount = widget.chatCount ?? 0;
      });
    }
  }

  void _navigateToScreen(Widget screen) {
    Get.offAll(() => screen);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onTap: () => _navigateToScreen(HomePage(selected: 1, userName: "")),
          ),
          _buildNavItem(
            svgIconPath: AppConstants.community,
            label: "Community",
            index: 2,
            onTap: () => _navigateToScreen(CommunityScreen(selected: 2)),
          ),
          _buildNavItemWithBadge(
            svgIconPath: AppConstants.chat1,
            label: "Chat",
            index: 3,
            badgeCount: _chatCount,
            onTap: () => _navigateToScreen(ChatScreen(selected: 3)),
          ),
          _buildNavItem(
            svgIconPath: AppConstants.cart,
            label: "My Cart",
            index: 4,
            onTap:
                () => _navigateToScreen(
                  AddToCartView(
                    selected: 4,
                    fromBottomBar: true,
                    isAmend: false,
                  ),
                ),
          ),
        ],
      ),
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
          onTap();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgIconPath,
            height: 22.sp,
            width: 22.sp,
            color: widget.selected == index ? AppColors.maincolor : Colors.grey,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  widget.selected == index ? AppColors.maincolor : Colors.grey,
              fontSize: 14.5.sp,
              fontFamily:
                  widget.selected == index
                      ? AppConstants.manropeBold
                      : AppConstants.manrope,
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

  Widget _buildNavItemWithBadge({
    required String svgIconPath,
    required String label,
    required int index,
    required int badgeCount,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.selected != index) {
          onTap();
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgIconPath,
                height: 22.sp,
                width: 22.sp,
                color:
                    widget.selected == index
                        ? AppColors.maincolor
                        : Colors.grey,
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      widget.selected == index
                          ? AppColors.maincolor
                          : Colors.grey,
                  fontSize: 14.5.sp,
                  fontFamily:
                      widget.selected == index
                          ? AppConstants.manropeBold
                          : AppConstants.manrope,
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
          if (badgeCount > 0)
            Positioned(
              top: 1.5.h,
              right: 0.2.w,
              child: Container(
                padding: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                  color:
                      widget.selected == index
                          ? AppColors.maincolor
                          : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5.sp),
                ),
                constraints: BoxConstraints(minWidth: 18.sp, minHeight: 18.sp),
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
