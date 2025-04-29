import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());
  Future<void> signup({required String email, required String password}) async {
    try {
      emit(SignUpLoading());
      final response = await getIt<SupabaseService>().signUp(
        email: email,
        password: password,
      );
      emit(SignUpSuccess(response: response));
    } catch (e) {
      emit(SignUpError(error: e));
    }
  }
}
