part of 'list_comments_cubit.dart';

@immutable
sealed class ListCommentsState {}

final class ListCommentsInitial extends ListCommentsState {}

final class ListCommentsLoading extends ListCommentsState {}

final class ListCommentsSuccess extends ListCommentsState {
  final dynamic response;

  ListCommentsSuccess({required this.response});
}

final class ListCommentsError extends ListCommentsState {
  final dynamic error;

  ListCommentsError({required this.error});
}
