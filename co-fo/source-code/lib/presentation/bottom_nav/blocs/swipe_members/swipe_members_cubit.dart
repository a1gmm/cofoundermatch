import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'swipe_members_state.dart';

class SwipeMembersCubit extends Cubit<SwipeMembersState> {
  SwipeMembersCubit() : super(SwipeMembersInitial());
  Future<void> swipe({required String swipeeId, required bool liked}) async {
    try {
      emit(SwipeMembersLoading());
      final response = await getIt<SupabaseService>().swipeUsers(
        swipeeId: swipeeId,
        liked: liked,
      );
      emit(SwipeMembersSuccess(response: response));
    } catch (e) {
      emit(SwipeMembersError(error: e));
    }
  }
}
