import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit() : super(SignInInitial());
  Future<void> signin({required String email, required String password}) async {
    try {
      emit(SignInLoading());
      final response = await getIt<SupabaseService>().signIn(
        email: email,
        password: password,
      );
      emit(SignInSuccess(response: response));
    } catch (e) {
      emit(SignInError(error: e));
    }
  }
}
