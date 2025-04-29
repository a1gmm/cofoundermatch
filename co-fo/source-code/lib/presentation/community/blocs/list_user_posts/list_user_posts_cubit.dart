import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'list_user_posts_state.dart';

class ListUserPostsCubit extends Cubit<ListUserPostsState> {
  ListUserPostsCubit() : super(ListUserPostsInitial());

  Future<void> list() async {
    try {
      emit(ListUserPostsLoading());
      final response = await getIt<SupabaseService>().listUserCommunityPosts();
      emit(ListUserPostsSuccess(response: response));
    } catch (e) {
      emit(ListUserPostsError(error: e));
    }
  }
}
