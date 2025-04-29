part of 'list_messages_cubit.dart';

@immutable
sealed class ListMessagesState {}

final class ListMessagesInitial extends ListMessagesState {}

final class ListMessagesLoading extends ListMessagesState {}

final class ListMessagesSuccess extends ListMessagesState {
  final dynamic response;

  ListMessagesSuccess({required this.response});
}

final class ListMessagesError extends ListMessagesState {
  final dynamic error;

  ListMessagesError({required this.error});
}
