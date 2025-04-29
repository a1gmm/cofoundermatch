import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'member_posts_state.dart';

class MemberPostsCubit extends Cubit<MemberPostsState> {
  MemberPostsCubit() : super(MemberPostsInitial());
  Future<void> list({required String memberId}) async {
    try {
      emit(MemberPostsLoading());
      final response = await getIt<SupabaseService>().listMemberCommunityPosts(
        memberId: memberId,
      );
      emit(MemberPostsSuccess(response: response));
    } catch (e) {
      emit(MemberPostsError(error: e));
    }
  }
}
