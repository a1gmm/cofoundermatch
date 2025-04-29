part of 'sign_up_cubit.dart';

@immutable
sealed class SignUpState {}

final class SignUpInitial extends SignUpState {}

final class SignUpLoading extends SignUpState {}

final class SignUpSuccess extends SignUpState {
  final AuthResponse response;

  SignUpSuccess({required this.response});
}

final class SignUpError extends SignUpState {
  final dynamic error;

  SignUpError({required this.error});
}
