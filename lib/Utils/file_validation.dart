import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class FileValidation {
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB limit
  static const List<String> allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];

  static Future<void> validate(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception("File does not exist: $path");
    }

    final int size = await file.length();
    if (size > maxFileSize) {
      throw Exception("File size exceeds 10MB limit.");
    }

    final String? mimeType = lookupMimeType(path);
    if (mimeType == null || !allowedMimeTypes.contains(mimeType)) {
      throw Exception("Unsupported file type: ${mimeType ?? 'unknown'}");
    }
  }

  static MediaType? getMediaType(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType != null && allowedMimeTypes.contains(mimeType)) {
      final parts = mimeType.split('/');
      return MediaType(parts[0], parts[1]);
    }
    return null;
  }
}
