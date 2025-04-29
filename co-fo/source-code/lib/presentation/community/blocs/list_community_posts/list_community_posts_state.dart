part of 'list_community_posts_cubit.dart';

@immutable
sealed class ListCommunityPostsState {}

final class ListCommunityPostsInitial extends ListCommunityPostsState {}

final class ListCommunityPostsLoading extends ListCommunityPostsState {}

final class ListCommunityPostsSuccess extends ListCommunityPostsState {
  final dynamic response;

  ListCommunityPostsSuccess({required this.response});
}

final class ListCommunityPostsError extends ListCommunityPostsState {
  final dynamic error;

  ListCommunityPostsError({required this.error});
}
