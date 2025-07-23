import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final IconData leadingIcon;
  final List<Widget> children;
  final double? fontSize;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.children,
    this.fontSize,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.leadingIcon, color: Colors.black, size: 20.sp),
                    SizedBox(width: 9.w),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: Colors.black,
                        fontSize:
                            widget.fontSize == null ? 18.sp : widget.fontSize,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Icon(
                  isExpanded
                      ? CupertinoIcons.chevron_down
                      : CupertinoIcons.right_chevron,
                  color: Colors.black,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) Column(children: widget.children),
      ],
    );
  }
}
