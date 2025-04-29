part of 'send_message_cubit.dart';

@immutable
sealed class SendMessageState {}

final class SendMessageInitial extends SendMessageState {}

final class SendMessageLoading extends SendMessageState {}

final class SendMessageSuccess extends SendMessageState {
  final dynamic response;

  SendMessageSuccess({required this.response});
}

final class SendMessageError extends SendMessageState {
  final dynamic error;

  SendMessageError({required this.error});
}
