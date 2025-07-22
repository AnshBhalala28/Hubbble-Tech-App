// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:wavee/comman/colors.dart';
//
// import 'downloadFunctions.dart';
//
// class PdfView extends StatefulWidget {
//   final String? link;
//
//   PdfView({
//     Key? key,
//     this.link,
//   }) : super(key: key);
//
//   @override
//   State<PdfView> createState() => _PdfViewState();
// }
//
// class _PdfViewState extends State<PdfView> {
//   String? downloadedFilePath;
//
//   @override
//   void initState() {
//     super.initState();
//     print('Link Is : ${widget.link}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.maincolor,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 5.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 4.w),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: () => Get.back(),
//                     icon: Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       color: Colors.white,
//                       size: 20.sp,
//                     ),
//                   ),
//                   Text(
//                     'View Pdf',
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontFamily: "task",
//                       letterSpacing: 1,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => downloadFile(
//                         widget.link ?? '',
//                         context,
//                         ((widget.link ?? '').split('/').last.split('.').first ??
//                             ''),
//                         ((widget.link ?? '').split('/').last.split('.').last ??
//                             '')),
//                     icon: Icon(
//                       Icons.file_download,
//                       size: 19.sp,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 1.h),
//             SizedBox(
//               height: 85.h,
//               child: _buildPdfViewer(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPdfViewer() {
//     if (widget.link != null && widget.link!.isNotEmpty) {
//       final link = widget.link!.trim();
//
//       try {
//         final uri = Uri.parse(link);
//
//         if (uri.scheme == 'file' && downloadedFilePath != null) {
//           return SfPdfViewer.file(File(downloadedFilePath!));
//         } else if (uri.scheme == 'http' || uri.scheme == 'https') {
//           return SfPdfViewer.network(
//             link,
//             onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
//               Fluttertoast.showToast(
//                 msg: 'Failed to load PDF',
//                 toastLength: Toast.LENGTH_SHORT,
//                 timeInSecForIosWeb: 1,
//                 backgroundColor: Colors.red,
//                 textColor: Colors.white,
//                 fontSize: 13.sp,
//               );
//             },
//           );
//         }
//       } catch (e) {
//         print('Error: Invalid URL format');
//         Fluttertoast.showToast(
//           msg: 'Invalid PDF URL',
//           toastLength: Toast.LENGTH_SHORT,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 13.sp,
//         );
//       }
//     }
//
//     return Center(
//       child: Text(
//         'No PDF available to display',
//         style: TextStyle(
//           color: Colors.white,
//           fontFamily: "task",
//           fontSize: 15.sp,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:wavee/comman/colors.dart';

import 'downloadFunctions.dart';

class PdfView extends StatefulWidget {
  final String? link;

  PdfView({Key? key, this.link}) : super(key: key);

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  String? downloadedFilePath;

  @override
  void initState() {
    super.initState();
    print('Link Is : ${widget.link}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maincolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  Text(
                    'View File',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: "task",
                      letterSpacing: 1,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        () => downloadFile(
                      widget.link ?? '',
                      context,
                      ((widget.link ?? '')
                          .split('/')
                          .last
                          .split('.')
                          .first ??
                          ''),
                      ((widget.link ?? '')
                          .split('/')
                          .last
                          .split('.')
                          .last ??
                          ''),
                    ),
                    icon: Icon(
                      Icons.file_download,
                      size: 19.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            SizedBox(height: 85.h, child: _buildFileViewer()),
          ],
        ),
      ),
    );
  }

  Widget _buildFileViewer() {
    final link = widget.link;

    if (link == null || link.isEmpty) {
      return _errorWidget("No file available to display");
    }

    final uri = Uri.tryParse(link);
    if (uri == null) {
      return _errorWidget("Invalid URL");
    }

    final extension = uri.path.split('.').last.toLowerCase();

    if (extension == 'pdf') {
      return SfPdfViewer.network(
        link,
        onDocumentLoadFailed: (details) {
          Fluttertoast.showToast(
            msg: 'Failed to load PDF',
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 13.sp,
          );
        },
      );
    } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
      return Center(
        child: Image.network(
          link,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
          errorBuilder:
              (context, error, stackTrace) =>
              _errorWidget("Failed to load image"),
        ),
      );
    } else {
      return _errorWidget("Unsupported file format: .$extension");
    }
  }

  Widget _errorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontFamily: "task",
          fontSize: 15.sp,
        ),
      ),
    );
  }
}
