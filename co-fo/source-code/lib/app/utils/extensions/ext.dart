import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

extension UNIExt on BuildContext {
  void hideKeyboard(BuildContext context) {
    final focusScope = FocusScope.of(context);
    focusScope.unfocus();
  }

  Widget isBusy(BuildContext context, {Size? size, double? width}) =>
      SizedBox.fromSize(
        size: size ?? const Size(24, 24),
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 4.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
          backgroundColor: Colors.grey.shade200,
        ),
      );
}

Future<Uint8List?> generateVideoThumbnail(String videoPath) async {
  try {
    final thumb = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      maxHeight: 300,
      quality: 75,
    );
    return thumb;
  } catch (e) {
    return null;
  }
}

  bool isVideoFile(File file) {
    final ext = file.path.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi');
  }
