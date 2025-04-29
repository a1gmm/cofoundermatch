import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

part 'multi_media_state.dart';

class MultiMediaCubit extends Cubit<MultiMediaState> {
  MultiMediaCubit() : super(MultiMediaInitial());

  Future<void> selectMedia() async {
    try {
      emit(MultiMediaLoading());
      final ImagePickerPlatform imagePickerImplementation =
          ImagePickerPlatform.instance;
      if (imagePickerImplementation is ImagePickerAndroid) {
        imagePickerImplementation.useAndroidPhotoPicker = true;
      }
      final media = await ImagePicker().pickMultipleMedia(limit: 3);
      List<File> validMedia = [];
      for (var i in media) {
        final String extension = path.extension(i.path).toLowerCase();
        final isImageExt = [
          '.jpg',
          '.jpeg',
          '.png',
          '.gif',
          '.bmp',
          '.webp',
        ].contains(extension);
        final isVideoExt = [
          '.mp4',
          '.mov',
          '.avi',
          '.mkv',
          '.wmv',
          '.flv',
        ].contains(extension);
        if (isImageExt || isVideoExt) {
          validMedia.add(File(i.path));
        }
      }
      emit(MultiMediaSuccess(response: validMedia));
    } catch (e) {
      emit(MultiMediaError(error: e));
    }
  }
}
