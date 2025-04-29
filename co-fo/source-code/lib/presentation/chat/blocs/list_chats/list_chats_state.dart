part of 'list_chats_cubit.dart';

@immutable
sealed class ListChatsState {}

final class ListChatsInitial extends ListChatsState {}

final class ListChatsLoading extends ListChatsState {}

final class ListChatsSuccess extends ListChatsState {
  final dynamic response;

  ListChatsSuccess({required this.response});
}

final class ListChatsError extends ListChatsState {
  final dynamic error;

  ListChatsError({required this.error});
}
