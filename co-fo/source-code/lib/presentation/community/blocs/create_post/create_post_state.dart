part of 'create_post_cubit.dart';

@immutable
sealed class CreatePostState {}

final class CreatePostInitial extends CreatePostState {}

final class CreatePostLoading extends CreatePostState {}

final class CreatePostSuccess extends CreatePostState {
  final dynamic response;

  CreatePostSuccess({required this.response});
}

final class CreatePostError extends CreatePostState {
  final dynamic error;

  CreatePostError({required this.error});
}
