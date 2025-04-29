import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uniapp/presentation/community/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, this.data});
  final dynamic data;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
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
                  child: PostDetailScreen(
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity(horizontal: -3, vertical: -3),
              leading: CircleAvatar(
                backgroundImage:
                    widget.data['profiles']['avatar']
                            .toString()
                            .isNotEmptyAndNotNull
                        ? CachedNetworkImageProvider(
                          widget.data['profiles']['avatar'],
                        )
                        : null,
              ),
              title: Text(widget.data['profiles']['username']),
              subtitle: Text(
                timeago.format(
                  DateTime.parse(widget.data['created_at']).toLocal(),
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: Colors.grey),
              ),
              trailing: Chip(
                backgroundColor:
                    widget.data['tag'] == 'project'
                        ? Colors.blue.withValues(alpha: 0.3)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -3, vertical: -3),
                label: Text(
                  widget.data['tag'],
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color:
                        widget.data['tag'] == 'project'
                            ? Colors.blue
                            : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
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
              commentCount: commentCount,
              likeCount: likeCount,
              postId: widget.data['id'],
              hasLiked: hasLiked,
            ),
          ],
        ).p(8),
      ),
    );
  }
}
