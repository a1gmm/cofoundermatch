part of 'sign_out_cubit.dart';

@immutable
sealed class SignOutState {}

final class SignOutInitial extends SignOutState {}

final class SignOutLoading extends SignOutState {}

final class SignOutSuccess extends SignOutState {
  final dynamic response;

  SignOutSuccess({required this.response});
}

final class SignOutError extends SignOutState {
  final dynamic error;

  SignOutError({required this.error});
}
