part of 'upload_image_cubit.dart';

@immutable
sealed class UploadImageState {}

final class UploadImageInitial extends UploadImageState {}

final class UploadImageLoading extends UploadImageState {}

final class UploadImageSuccess extends UploadImageState {
  final dynamic response;

  UploadImageSuccess({required this.response});
}

final class UploadImageError extends UploadImageState {
  final dynamic error;

  UploadImageError({required this.error});
}
