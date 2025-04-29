part of 'list_user_posts_cubit.dart';

@immutable
sealed class ListUserPostsState {}

final class ListUserPostsInitial extends ListUserPostsState {}

final class ListUserPostsLoading extends ListUserPostsState {}

final class ListUserPostsSuccess extends ListUserPostsState {
  final dynamic response;

  ListUserPostsSuccess({required this.response});
}

final class ListUserPostsError extends ListUserPostsState {
  final dynamic error;

  ListUserPostsError({required this.error});
}
