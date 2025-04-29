import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'list_comments_state.dart';

class ListCommentsCubit extends Cubit<ListCommentsState> {
  ListCommentsCubit() : super(ListCommentsInitial());
  Future<void> list({required String postId}) async {
    try {
      emit(ListCommentsLoading());
      final response = await getIt<SupabaseService>().listComments(
        postId: postId,
      );
      emit(ListCommentsSuccess(response: response));
    } catch (e) {
      emit(ListCommentsError(error: e));
    }
  }
}
