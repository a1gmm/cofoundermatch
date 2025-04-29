import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'create_comment_state.dart';

class CreateCommentCubit extends Cubit<CreateCommentState> {
  CreateCommentCubit() : super(CreateCommentInitial());

  Future<void> create({
    required String commentText,
    required String postId,
  }) async {
    try {
      emit(CreateCommentLoading());
      final response = await getIt<SupabaseService>().createComment(
        commentText: commentText,
        postId: postId,
      );
      emit(CreateCommentSuccess(response: response[0]));
    } catch (e) {
      emit(CreateCommentError(error: e));
    }
  }
}
