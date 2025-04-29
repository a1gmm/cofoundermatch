part of 'media_picker_cubit.dart';

@immutable
sealed class MediaPickerState {}

final class MediaPickerInitial extends MediaPickerState {}

final class MediaPickerLoading extends MediaPickerState {}

final class MediaPickerSuccess extends MediaPickerState {
  MediaPickerSuccess({required this.image});
  final File image;
}

final class MediaPickerError extends MediaPickerState {
  MediaPickerError({required this.error});
  final dynamic error;
}

