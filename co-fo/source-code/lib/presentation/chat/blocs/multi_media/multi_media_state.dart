part of 'multi_media_cubit.dart';

@immutable
sealed class MultiMediaState {}

final class MultiMediaInitial extends MultiMediaState {}

final class MultiMediaLoading extends MultiMediaState {}

final class MultiMediaSuccess extends MultiMediaState {
  final List<File> response;

  MultiMediaSuccess({required this.response});
}

final class MultiMediaError extends MultiMediaState {
  final dynamic error;

  MultiMediaError({required this.error});
}
