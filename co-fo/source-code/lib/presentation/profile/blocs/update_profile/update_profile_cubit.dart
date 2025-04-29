import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';
import 'package:uniapp/data/imports.dart';

part 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit() : super(UpdateProfileInitial());
  Future<void> update({
    required String username,
    required String userType,
    required String bio,
    required List<String> skills,
    required String title,
  }) async {
    try {
      emit(UpdateProfileLoading());
      final response = await getIt<SupabaseService>().updateUserProfile(
        username: username,
        userType: userType,
        bio: bio,
        skills: skills,
        title: title,
      );
      emit(UpdateProfileSuccess(response: response));
      await getIt<UserProfileRepository>().save(response);
    } catch (e) {
      emit(UpdateProfileError(error: e));
    }
  }
}
