part of 'update_profile_cubit.dart';

@immutable
sealed class UpdateProfileState {}

final class UpdateProfileInitial extends UpdateProfileState {}

final class UpdateProfileLoading extends UpdateProfileState {}

final class UpdateProfileSuccess extends UpdateProfileState {
  final CurrentUser response;

  UpdateProfileSuccess({required this.response});
}

final class UpdateProfileError extends UpdateProfileState {
  final dynamic error;

  UpdateProfileError({required this.error});
}
