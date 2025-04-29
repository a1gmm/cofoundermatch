part of 'create_comment_cubit.dart';

@immutable
sealed class CreateCommentState {}

final class CreateCommentInitial extends CreateCommentState {}

final class CreateCommentLoading extends CreateCommentState {}

final class CreateCommentSuccess extends CreateCommentState {
  final dynamic response;

  CreateCommentSuccess({required this.response});
}

final class CreateCommentError extends CreateCommentState {
  final dynamic error;

  CreateCommentError({required this.error});
}
