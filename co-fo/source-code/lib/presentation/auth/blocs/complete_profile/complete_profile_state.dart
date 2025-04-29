part of 'complete_profile_cubit.dart';

@immutable
sealed class CompleteProfileState {}

final class CompleteProfileInitial extends CompleteProfileState {}

final class CompleteProfileLoading extends CompleteProfileState {}

final class CompleteProfileSuccess extends CompleteProfileState {
  final dynamic response;

  CompleteProfileSuccess({required this.response});
}

final class CompleteProfileError extends CompleteProfileState {
  final dynamic error;

  CompleteProfileError({required this.error});
}
