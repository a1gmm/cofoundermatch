import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';
import 'package:uniapp/data/imports.dart';

part 'upload_image_state.dart';

class UploadImageCubit extends Cubit<UploadImageState> {
  UploadImageCubit() : super(UploadImageInitial());

  Future<void> upload({
    required String userId,
    required File img,
  }) async {
    try {
      emit(UploadImageLoading());
      final response = await getIt<SupabaseService>().uploadProfileImage(
        img: img,
      );
      emit(UploadImageSuccess(response: response));
      await getIt<UserProfileRepository>().updateUserAvatar(
        userId: userId,
        avatar: response,
      );
    } catch (e) {
      emit(UploadImageError(error: e));
    }
  }
}
