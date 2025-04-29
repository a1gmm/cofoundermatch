import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';
import 'package:uniapp/data/source/local/db/repository.dart';
import 'package:uniapp/data/source/local/models/current_user.dart';

part 'read_profile_state.dart';

class ReadProfileCubit extends Cubit<ReadProfileState> {
  ReadProfileCubit() : super(ReadProfileInitial());

  Future<void> readCurrentUserProfile() async {
    try {
      emit(ReadProfileLoading());
      final response = await getIt<SupabaseService>().getUserProfile();
      if (response == null) {
        emit(ReadProfileSuccess(response: response));
      } else {
        emit(ReadProfileSuccess(response: response));
        await getIt<UserProfileRepository>().save(response);
      }
    } catch (e) {
      emit(ReadProfileError(error: e));
    }
  }
}
