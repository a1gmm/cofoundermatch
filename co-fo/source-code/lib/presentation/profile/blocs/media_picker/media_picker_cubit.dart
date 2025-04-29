import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/presentation/profile/repository/gallery_repository.dart';

part 'media_picker_state.dart';

class MediaPickerCubit extends Cubit<MediaPickerState> {
  MediaPickerCubit() : super(MediaPickerInitial());

  Future<void> selectImage() async {
    try {
      emit(MediaPickerLoading());
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      final croppedImage = await GalleryRepository().cropImage(
        pickedImage!.path,
      );
      emit(MediaPickerSuccess(image: File(croppedImage)));
    } catch (e) {
      emit(MediaPickerError(error: e));
    }
  }
}
