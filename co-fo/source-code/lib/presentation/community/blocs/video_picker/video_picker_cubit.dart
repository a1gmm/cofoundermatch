import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'video_picker_state.dart';

class VideoPickerCubit extends Cubit<VideoPickerState> {
  VideoPickerCubit() : super(VideoPickerInitial());

  Future<void> selectVideo() async {
    try {
      emit(VideoPickerLoading());
      final video = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 5),
      );
      if (video!.path.toLowerCase().endsWith('.mp4') ||
          video.path.toLowerCase().endsWith('.mov') ||
          video.path.toLowerCase().endsWith('.avi') ||
          video.path.toLowerCase().endsWith('.mkv')) {
        emit(VideoPickerSuccess(response: File(video.path)));
      } else {
        emit(VideoPickerError(error: 'Not supported video format'));
      }
    } catch (e) {
      emit(VideoPickerError(error: e));
    }
  }
}
