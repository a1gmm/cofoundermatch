import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uniapp/app/imports.dart';

class GalleryRepository {
  Future<String> cropImage(String filePath) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Colors.white,
          cropFrameColor: Colors.white,
          toolbarWidgetColor: pk,
          activeControlsWidgetColor: pk,
          hideBottomControls: true,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          minimumAspectRatio: 1,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    return croppedImage!.path;
  }
}
