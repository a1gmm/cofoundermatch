import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'list_community_posts_state.dart';

class ListCommunityPostsCubit extends Cubit<ListCommunityPostsState> {
  ListCommunityPostsCubit() : super(ListCommunityPostsInitial());

  Future<void> list() async {
    try {
      emit(ListCommunityPostsLoading());
      final response = await getIt<SupabaseService>().listCommunityPosts();
      emit(ListCommunityPostsSuccess(response: response));
    } catch (e) {
      emit(ListCommunityPostsError(error: e));
    }
  }
}
