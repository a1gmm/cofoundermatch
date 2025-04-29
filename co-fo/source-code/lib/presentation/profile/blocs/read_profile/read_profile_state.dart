part of 'read_profile_cubit.dart';

@immutable
sealed class ReadProfileState {}

final class ReadProfileInitial extends ReadProfileState {}

final class ReadProfileLoading extends ReadProfileState {}

final class ReadProfileSuccess extends ReadProfileState {
  final CurrentUser? response;

  ReadProfileSuccess({required this.response});
}

final class ReadProfileError extends ReadProfileState {
  final dynamic error;

  ReadProfileError({required this.error});
}
