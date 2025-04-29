part of 'post_cubit.dart';

class PostCubitStore {
  static final _instances = <String, PostCubit>{};

  static PostCubit get({
    required String postId,
    int? likeCount,
    int? commentCount,
    bool? hasLiked,
  }) {
    return _instances.putIfAbsent(postId, () {
      if (likeCount == null || commentCount == null || hasLiked == null) {
        throw ArgumentError(
          'Initial values must be provided when creating a new PostCubit',
        );
      }

      return PostCubit(
        postId: postId,
        initialLikeCount: likeCount,
        initialCommentCount: commentCount,
        initialHasLiked: hasLiked,
      );
    });
  }

  static void dispose(String postId) {
    _instances.remove(postId)?.close();
  }

  static void reset() {
    _instances.forEach((_, cubit) {
      cubit.close(); 
    });
    _instances.clear(); 
  }
}
