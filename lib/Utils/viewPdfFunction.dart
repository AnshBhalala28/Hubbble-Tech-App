import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'colors.dart';

class PdfView extends StatefulWidget {
  final String? link;

  const PdfView({super.key, this.link});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  @override
  void initState() {
    super.initState();
    log("FILE LINK => ${widget.link}");
  }

  // 🔹 SHARE
  void _shareLink() {
    if (widget.link != null && widget.link!.isNotEmpty) {
      Share.share(widget.link!, subject: 'Check out this file!');
    } else {
      Fluttertoast.showToast(msg: "Cannot share empty link");
    }
  }

  // 🔹 EXTENSION FROM QUERY PARAM
  String _getExtension(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';

    final path = uri.queryParameters['path'];
    if (path == null) return '';

    return path.split('.').last.toLowerCase();
  }

  // 🔹 FILE NAME
  String _getFileName(String url) {
    final uri = Uri.tryParse(url);
    final path = uri?.queryParameters['path'];
    return path?.split('/').last ?? 'View File';
  }

  @override
  Widget build(BuildContext context) {
    final fileName =
        widget.link != null ? _getFileName(widget.link!) : 'View File';

    return Scaffold(
      backgroundColor: AppColors.maincolor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      fileName,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: "task",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _shareLink,
                    icon: Icon(Icons.share, size: 19.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Expanded(child: _buildFileViewer()),
          ],
        ),
      ),
    );
  }

  Widget _buildFileViewer() {
    final link = widget.link;
    if (link == null || link.isEmpty) {
      return _errorWidget("No file available");
    }

    final extension = _getExtension(link);
    log("DETECTED EXTENSION => $extension");

    /// 📄 PDF
    if (extension == 'pdf') {
      return SfPdfViewer.network(
        link,
        onDocumentLoadFailed: (details) {
          Fluttertoast.showToast(
            msg: "Failed to load PDF",
            backgroundColor: Colors.red,
          );
        },
      );
    }

    /// 🖼 IMAGE
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4,
        child: Center(
          child: Image.network(
            link,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (_, __, ___) => _errorWidget("Failed to load image"),
          ),
        ),
      );
    }

    return _errorWidget("Unsupported file format");
  }

  Widget _errorWidget(String msg) {
    return Center(
      child: Text(
        msg,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
          fontFamily: "task",
        ),
      ),
    );
  }
}
