import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit() : super(CreatePostInitial());

  Future<void> create({
    required String tag,
    required String title,
    required String description,
    List<File>? mediaFiles,
  }) async {
    try {
      emit(CreatePostLoading());
      final response = await getIt<SupabaseService>().createPost(
        tag: tag,
        title: title,
        description: description,
        mediaFiles: mediaFiles,
      );
      emit(CreatePostSuccess(response: response));
    } catch (e) {
      emit(CreatePostError(error: e));
    }
  }
}
