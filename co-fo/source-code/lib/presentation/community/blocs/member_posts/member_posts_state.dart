part of 'member_posts_cubit.dart';

@immutable
sealed class MemberPostsState {}

final class MemberPostsInitial extends MemberPostsState {}


final class MemberPostsLoading extends MemberPostsState {}

final class MemberPostsSuccess extends MemberPostsState {
  final dynamic response;

  MemberPostsSuccess({required this.response});
}

final class MemberPostsError extends MemberPostsState {
  final dynamic error;

  MemberPostsError({required this.error});
}
