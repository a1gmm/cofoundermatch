import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';
import 'package:uniapp/data/imports.dart';
import 'package:uniapp/presentation/community/blocs/post/post_cubit.dart';

part 'sign_out_state.dart';

class SignOutCubit extends Cubit<SignOutState> {
  SignOutCubit() : super(SignOutInitial());
  Future<void> signout() async {
    try {
      emit(SignOutLoading());
      final response = await getIt<SupabaseService>().signout();
      await getIt<UserProfileRepository>().deleteUserProfile();
      PostCubitStore.reset();
      emit(SignOutSuccess(response: response));
    } catch (e) {
      emit(SignOutError(error: e));
    }
  }
}
