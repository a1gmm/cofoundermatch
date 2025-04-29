part of 'sign_in_cubit.dart';

@immutable
sealed class SignInState {}

final class SignInInitial extends SignInState {}

final class SignInLoading extends SignInState {}

final class SignInSuccess extends SignInState {
  final AuthResponse response;

  SignInSuccess({required this.response});
}

final class SignInError extends SignInState {
  final dynamic error;

  SignInError({required this.error});
}
