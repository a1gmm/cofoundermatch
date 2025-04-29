import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:like_button/like_button.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uniapp/presentation/community/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class UserPostCard extends StatefulWidget {
  const UserPostCard({super.key, this.data, required this.deleted});
  final dynamic data;
  final Function(String)? deleted;

  @override
  State<UserPostCard> createState() => _UserPostCardState();
}

class _UserPostCardState extends State<UserPostCard> {
  late int commentCount;
  late int likeCount;
  late bool hasLiked;

  List<String> mediaUrls = [];

  @override
  initState() {
    _initData();
    super.initState();
  }

  _initData() {
    commentCount = widget.data['comment_count'];
    likeCount = widget.data['like_count'];
    hasLiked = widget.data['has_liked'];

    if (widget.data['media'] != null) {
      mediaUrls = widget.data['media'].cast<String>();
    }
    _onChanged();
  }

  _onChanged() => setState(() {});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => ListCommentsCubit()),
                    BlocProvider(create: (context) => LikePostCubit()),
                    BlocProvider(create: (context) => CreateCommentCubit()),
                  ],
                  child: UserPostDetailScreen(
                    postDetailArgs: PostDetailArgs(
                      data: widget.data,
                      likeCount: likeCount,
                      commentCount: commentCount,
                      hasLiked: hasLiked,
                    ),
                  ),
                ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.3),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity(horizontal: -3, vertical: -3),
                  label: Text(
                    widget.data['tag'],
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Text(
                  timeago.format(
                    DateTime.parse(widget.data['created_at']).toLocal(),
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
              ],
            ),
            Gap(4),
            GalleryGrid(mediaUrls: mediaUrls).pOnly(bottom: 4),

            Text(
              widget.data['title'],
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500),
            ),
            Gap(4),
            Text(
              widget.data['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w300),
            ),
            Gap(8),
            LikeCommentWidget(
              commentCount: widget.data['comment_count'],
              likeCount: widget.data['like_count'],
              postId: widget.data['id'],
              hasLiked: widget.data['has_liked'],
            ),
            BlocListener<DeletePostCubit, DeletePostState>(
              listener: (context, state) {
                if (state is DeletePostError) {
                  context.loaderOverlay.hide();
                  context.showToast(msg: 'Something went wrong');
                }
                if (state is DeletePostLoading) {
                  context.loaderOverlay.show();
                }
                if (state is DeletePostSuccess) {
                  context.loaderOverlay.hide();
                  widget.deleted!(widget.data['id']);
                }
              },
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  visualDensity: VisualDensity(vertical: -3, horizontal: -3),

                  icon: Icon(Symbols.delete_forever_rounded),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (contextf) {
                        return AlertDialog.adaptive(
                          title: Text('Delete post'),
                          content: Text('This action is irreversable'),
                          actionsPadding: EdgeInsets.zero,
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(contextf).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<DeletePostCubit>().delete(
                                  postId: widget.data['id'],
                                  mediaUrl: mediaUrls,
                                );
                                Navigator.of(contextf).pop();
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ).p(8),
      ),
    );
  }
}

class LikeCommentWidget extends StatelessWidget {
  final String postId;
  final int likeCount;
  final int commentCount;
  final bool hasLiked;

  const LikeCommentWidget({
    super.key,
    required this.postId,
    required this.likeCount,
    required this.commentCount,
    required this.hasLiked,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = PostCubitStore.get(
      postId: postId,
      likeCount: likeCount,
      commentCount: commentCount,
      hasLiked: hasLiked,
    );

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeButton(
                size: 24,
                isLiked: state.hasLiked,
                likeCount: state.likeCount,
                circleColor: const CircleColor(
                  start: Color(0xff00ddff),
                  end: Color(0xff0099cc),
                ),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Color(0xff33b5e5),
                  dotSecondaryColor: Color(0xff0099cc),
                ),
                likeBuilder: (isLiked) {
                  return Icon(
                    Symbols.thumb_up,
                    color: isLiked ? Colors.deepPurpleAccent : Colors.grey,
                    fill: isLiked ? 1 : 0,
                    size: 18,
                  );
                },
                onTap: (isCurrentlyLiked) async {
                  final newState = !isCurrentlyLiked;
                  cubit.updateLike(newState);
                  BlocProvider.of<LikePostCubit>(context).like(postId: postId);
                  return newState;
                },
                countBuilder: (count, isLiked, text) {
                  return Text(
                    '${count ?? 0}',
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              ),
              const SizedBox(width: 6),
              const Icon(Symbols.chat_bubble, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                state.commentCount.toString(),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          );
        },
      ),
    );
  }
}
