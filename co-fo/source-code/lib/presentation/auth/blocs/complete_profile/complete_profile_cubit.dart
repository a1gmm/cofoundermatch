import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';
import 'package:uniapp/data/imports.dart';

part 'complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  CompleteProfileCubit() : super(CompleteProfileInitial());

  Future<void> completeProfile({
    required String username,
    required String userType,
    required String bio,
    required List<String> skills,
    required String title,
  }) async {
    try {
      emit(CompleteProfileLoading());
      final response = await getIt<SupabaseService>().completeUserProfile(
        username: username,
        userType: userType,
        bio: bio,
        skills: skills,
        title: title,
      );
      emit(CompleteProfileSuccess(response: response));
      await getIt<UserProfileRepository>().save(response);
    } catch (e) {
      emit(CompleteProfileError(error: e));
    }
  }
}
