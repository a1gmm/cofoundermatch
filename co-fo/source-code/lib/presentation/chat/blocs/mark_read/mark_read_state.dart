part of 'mark_read_cubit.dart';

@immutable
sealed class MarkReadState {}

final class MarkReadInitial extends MarkReadState {}

final class MarkReadLoading extends MarkReadState {}

final class MarkReadSuccess extends MarkReadState {
  final dynamic response;

  MarkReadSuccess({required this.response});
}

final class MarkReadError extends MarkReadState {
  final dynamic error;

  MarkReadError({required this.error});
}
