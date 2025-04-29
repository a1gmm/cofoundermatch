import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'list_members_state.dart';

class ListMembersCubit extends Cubit<ListMembersState> {
  ListMembersCubit() : super(ListMembersInitial());
  Future<void> list({required String userType}) async {
    try {
      emit(ListMembersLoading());
      final response = await getIt<SupabaseService>().fetchMembers(
        userType: userType,
      );
      emit(ListMembersSuccess(response: response));
    } catch (e) {
      emit(ListMembersError(error: e));
    }
  }
}
