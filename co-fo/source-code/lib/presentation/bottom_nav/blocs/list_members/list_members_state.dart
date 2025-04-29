part of 'list_members_cubit.dart';

@immutable
sealed class ListMembersState {}

final class ListMembersInitial extends ListMembersState {}

final class ListMembersLoading extends ListMembersState {}

final class ListMembersSuccess extends ListMembersState {
  final dynamic response;

  ListMembersSuccess({required this.response});
}

final class ListMembersError extends ListMembersState {
  final dynamic error;

  ListMembersError({required this.error});
}
