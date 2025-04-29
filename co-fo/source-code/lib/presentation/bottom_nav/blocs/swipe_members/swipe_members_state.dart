part of 'swipe_members_cubit.dart';

@immutable
sealed class SwipeMembersState {}

final class SwipeMembersInitial extends SwipeMembersState {}

final class SwipeMembersLoading extends SwipeMembersState {}

final class SwipeMembersSuccess extends SwipeMembersState {
  final dynamic response;

  SwipeMembersSuccess({required this.response});
}

final class SwipeMembersError extends SwipeMembersState {
  final dynamic error;

  SwipeMembersError({required this.error});
}
