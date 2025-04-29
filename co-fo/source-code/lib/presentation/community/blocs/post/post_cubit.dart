import 'package:bloc/bloc.dart';

part 'post_store.dart';

class PostState {
  final int likeCount;
  final int commentCount;
  final bool hasLiked;
  final String postId;

  PostState({
    required this.likeCount,
    required this.commentCount,
    required this.hasLiked,
    required this.postId,
  });

  PostState copyWith({int? likeCount, int? commentCount, bool? hasLiked}) {
    return PostState(
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      hasLiked: hasLiked ?? this.hasLiked,
      postId: postId,
    );
  }
}

class PostCubit extends Cubit<PostState> {
  PostCubit({
    required String postId,
    required int initialLikeCount,
    required int initialCommentCount,
    required bool initialHasLiked,
  }) : super(
         PostState(
           likeCount: initialLikeCount,
           commentCount: initialCommentCount,
           hasLiked: initialHasLiked,
           postId: postId,
         ),
       );

  void updateLike(bool liked) {
    emit(
      state.copyWith(
        hasLiked: liked,
        likeCount: state.likeCount + (liked ? 1 : -1),
      ),
    );
  }

  void updateCommentCount(int newCount) {
    emit(state.copyWith(commentCount: newCount));
  }

  void incrementComment() {
    emit(state.copyWith(commentCount: state.commentCount + 1));
  }
}
