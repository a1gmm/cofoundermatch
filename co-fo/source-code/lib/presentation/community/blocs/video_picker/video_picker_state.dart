part of 'video_picker_cubit.dart';

@immutable
sealed class VideoPickerState {}

final class VideoPickerInitial extends VideoPickerState {}

final class VideoPickerLoading extends VideoPickerState {}

final class VideoPickerSuccess extends VideoPickerState {
  final File response;

  VideoPickerSuccess({required this.response});
}

final class VideoPickerError extends VideoPickerState {
  final dynamic error;

  VideoPickerError({required this.error});
}
