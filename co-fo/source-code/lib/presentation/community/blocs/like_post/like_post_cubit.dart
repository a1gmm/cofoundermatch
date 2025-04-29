import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'like_post_state.dart';

class LikePostCubit extends Cubit<LikePostState> {
  LikePostCubit() : super(LikePostInitial());

  Future<void> like({required String postId}) async {
    try {
      emit(LikePostLoading());
      final response = await getIt<SupabaseService>().likePost(postId: postId);
      emit(LikePostSuccess(response: response));
    } catch (e) {
      emit(LikePostError(error: e));
    }
  }
}
