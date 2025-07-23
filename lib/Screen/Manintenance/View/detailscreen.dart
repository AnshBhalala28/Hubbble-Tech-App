import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../comman/Custom_AppBar.dart';
import '../../../comman/SideMenu.dart';

class Detail_Screen extends StatefulWidget {
  const Detail_Screen({super.key});

  @override
  State<Detail_Screen> createState() => _Detail_ScreenState();
}

class _Detail_ScreenState extends State<Detail_Screen> {
  final GlobalKey<ScaffoldState> detailsKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: detailsKey,
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 4.h),
            TitleBar(
              back: () {
                Get.back();
              },
              title: 'Details Screen',
              drawerCallback: () {
                detailsKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}
