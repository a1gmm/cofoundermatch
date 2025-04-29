part of 'delete_post_cubit.dart';

@immutable
sealed class DeletePostState {}

final class DeletePostInitial extends DeletePostState {}

final class DeletePostLoading extends DeletePostState {}

final class DeletePostSuccess extends DeletePostState {
  final dynamic response;

  DeletePostSuccess({required this.response});
}

final class DeletePostError extends DeletePostState {
  final dynamic error;

  DeletePostError({required this.error});
}
