import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'delete_post_state.dart';

class DeletePostCubit extends Cubit<DeletePostState> {
  DeletePostCubit() : super(DeletePostInitial());

  Future<void> delete({
    required String postId,
    required List<String> mediaUrl,
  }) async {
    try {
      emit(DeletePostLoading());
      final response = await getIt<SupabaseService>().deletePost(
        postId: postId,
        mediaUrl: mediaUrl,
      );
      emit(DeletePostSuccess(response: response));
    } catch (e) {
      emit(DeletePostError(error: e));
    }
  }
}
