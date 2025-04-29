import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/presentation/community/imports.dart';
import 'package:uniapp/presentation/widgets/standard_button.dart';
import 'package:velocity_x/velocity_x.dart';

class PostDetailArgs {
  final dynamic data;
  final int likeCount;
  final int commentCount;
  final bool hasLiked;
  PostDetailArgs({
    required this.data,
    required this.likeCount,
    required this.commentCount,
    required this.hasLiked,
  });
}

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postDetailArgs});
  final PostDetailArgs postDetailArgs;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late int commentCount;
  late int likeCount;
  late bool hasLiked;
  List<String> mediaUrls = [];

  bool commentsLoaded = false;

  List<Map<String, dynamic>> comments = [];
  final commentCtrl = TextEditingController();

  @override
  initState() {
    _initData();
    super.initState();
  }

  _initData() {
    commentCount = widget.postDetailArgs.data['comment_count'];
    likeCount = widget.postDetailArgs.data['like_count'];
    hasLiked = widget.postDetailArgs.data['has_liked'];
    if (widget.postDetailArgs.data['media'] != null) {
      mediaUrls = widget.postDetailArgs.data['media'].cast<String>();
    }
    _onChanged();
    BlocProvider.of<ListCommentsCubit>(
      context,
    ).list(postId: widget.postDetailArgs.data['id']);
  }

  _onChanged() => setState(() {});

  void _submitComment(BuildContext context, String postId) {
    final text = commentCtrl.text.trim();
    if (text.isEmpty) return;

    context.read<CreateCommentCubit>().create(
      commentText: text,
      postId: postId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.postDetailArgs.data['id'];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Post')),
      bottomNavigationBar:
          commentsLoaded
              ? Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  right: 8,
                  left: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'comment',
                        controller: commentCtrl,
                        onChanged: (_) => _onChanged(),
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Post comment',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _submitComment(context, postId),
                      ),
                    ),
                    const SizedBox(width: 8),
                    BlocConsumer<CreateCommentCubit, CreateCommentState>(
                      listener: (context, state) {
                        if (state is CreateCommentSuccess) {
                          comments.insert(0, state.response);
                          commentCtrl.clear();
                          context.hideKeyboard(context);
                          _onChanged();

                          PostCubitStore.get(postId: postId).incrementComment();
                        }
                      },
                      builder: (context, state) {
                        final isDisabled = commentCtrl.text.trim().isEmpty;

                        if (state is CreateCommentLoading) {
                          return StandardButton(
                            text: 'Post',
                            width: .2.sw,
                            height: 40,
                            onPressed: null,
                          ).shimmer();
                        }

                        return StandardButton(
                          text: 'Post',
                          width: .2.sw,
                          height: 40,
                          onPressed:
                              isDisabled
                                  ? null
                                  : () => _submitComment(context, postId),
                        );
                      },
                    ),
                  ],
                ),
              )
              : null,
      body: GestureDetector(
        onTap: () => {FocusScope.of(context).unfocus()},
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity(
                        horizontal: -3,
                        vertical: -3,
                      ),
                      leading: CircleAvatar(
                        backgroundImage:
                            widget.postDetailArgs.data['profiles']['avatar']
                                    .toString()
                                    .isNotEmptyAndNotNull
                                ? CachedNetworkImageProvider(
                                  widget
                                      .postDetailArgs
                                      .data['profiles']['avatar'],
                                )
                                : null,
                      ),
                      title: Text(
                        widget.postDetailArgs.data['profiles']['username'],
                      ),
                      subtitle: Text(
                        timeago.format(
                          DateTime.parse(
                            widget.postDetailArgs.data['created_at'],
                          ).toLocal(),
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                      ),
                      trailing: Chip(
                        backgroundColor:
                            widget.postDetailArgs.data['tag'] == 'project'
                                ? Colors.blue.withValues(alpha: 0.3)
                                : Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.3),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity(
                          horizontal: -3,
                          vertical: -3,
                        ),
                        label: Text(
                          widget.postDetailArgs.data['tag'],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color:
                                widget.postDetailArgs.data['tag'] == 'project'
                                    ? Colors.blue
                                    : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    GalleryGrid(mediaUrls: mediaUrls).pOnly(bottom: 4),
                    Text(
                      widget.postDetailArgs.data['title'],
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gap(4),
                    Text(
                      widget.postDetailArgs.data['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Gap(8),
                    LikeCommentWidget(
                      commentCount: commentCount,
                      likeCount: likeCount,
                      postId: widget.postDetailArgs.data['id'],
                      hasLiked: hasLiked,
                    ),
                  ],
                ).p(8),
              ),

              Gap(16),
              Text('Comments', style: Theme.of(context).textTheme.bodyLarge),
              BlocConsumer<ListCommentsCubit, ListCommentsState>(
                listener: (context, state) {
                  if (state is ListCommentsSuccess) {
                    commentsLoaded = true;
                    if (comments.isEmpty) {
                      comments = state.response;
                    } else {
                      comments.addAll(
                        state.response.where(
                          (comment) => !comments.contains(comment),
                        ),
                      );
                    }
                    _onChanged();
                  }
                },
                builder:
                    (context, state) => switch (state) {
                      ListCommentsSuccess() => ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            leading: CircleAvatar(),
                            title: Text(
                              comments[index]['profiles']['username'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: ReadMoreText(
                              comments[index]['comment_text'],
                              trimMode: TrimMode.Line,
                              trimLines: 2,
                              style: Theme.of(context).textTheme.bodyMedium,
                              colorClickableText: context.primaryColor,
                              trimCollapsedText: 'more',
                              trimExpandedText: 'less',
                            ),
                            trailing: Text(
                              timeago.format(
                                DateTime.parse(
                                  comments[index]['created_at'],
                                ).toLocal(),
                              ),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(color: Colors.grey),
                            ),
                          );
                        },
                        separatorBuilder:
                            (BuildContext context, int index) =>
                                const Divider(),
                        itemCount: comments.length,
                      ),
                      _ => context.isBusy(context),
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
