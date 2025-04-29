part of 'like_post_cubit.dart';

@immutable
sealed class LikePostState {}

final class LikePostInitial extends LikePostState {}

final class LikePostLoading extends LikePostState {}

final class LikePostSuccess extends LikePostState {
  final dynamic response;

  LikePostSuccess({required this.response});
}

final class LikePostError extends LikePostState {
  final dynamic error;

  LikePostError({required this.error});
}
