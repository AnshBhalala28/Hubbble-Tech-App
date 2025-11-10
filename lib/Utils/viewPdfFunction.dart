import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart'; // <-- 1. આ ઈમ્પોર્ટ ઉમેરો
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'colors.dart';

// આ તમારી downloadFunctions.dart ફાઇલ છે (જોકે આ કોડમાં તેનો ઉપયોગ નથી)
// import 'downloadFunctions.dart';

class PdfView extends StatefulWidget {
  final String? link;

  const PdfView({super.key, this.link});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  String? downloadedFilePath;

  @override
  void initState() {
    super.initState();
  }

  // <-- 2. શેર ફંક્શન ઉમેરો
  void _shareLink() {
    if (widget.link != null && widget.link!.isNotEmpty) {
      Share.share(widget.link!, subject: 'Check out this file!');
    } else {
      Fluttertoast.showToast(
        msg: "Cannot share empty link",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // <-- 3. ફાઇલનું નામ લિંકમાંથી મેળવો
    final String fileName = widget.link?.split('/').last ?? 'View File';

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
                // <-- લેઆઉટ સુધાર્યું
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  // <-- 4. ડાયનેમિક ફાઇલ નામ બતાવો
                  Expanded(
                    child: Text(
                      fileName,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        // ફોન્ટ સાઈઝ થોડી નાની કરી
                        fontFamily: "task",
                        letterSpacing: 1,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // <-- 5. નવું શેર બટન
                  IconButton(
                    onPressed: _shareLink, // શેર ફંક્શન કોલ કરો
                    icon: Icon(Icons.share, size: 19.sp, color: Colors.white),
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
    } else if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      // <-- 6. ઇમેજને InteractiveViewer માં મૂકો
      return InteractiveViewer(
        panEnabled: true, // પેન કરવા માટે
        minScale: 0.5, // મિનિમમ ઝૂમ
        maxScale: 4.0, // મેક્સિમમ ઝૂમ
        child: Center(
          child: Image.network(
            link,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ); // કલર ઉમેર્યો
            },
            errorBuilder:
                (context, error, stackTrace) =>
                    _errorWidget("Failed to load image"),
          ),
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
