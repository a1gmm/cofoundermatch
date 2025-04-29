import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/presentation/chat/imports.dart';
import 'package:uniapp/presentation/community/imports.dart';
import 'package:velocity_x/velocity_x.dart';

// Models
class ChatArgs {
  final String threadId;
  final String currentUserId;
  final String recepientId;
  final String recepientName;
  final String avatar;
  final int unreadCount;
  ChatArgs({
    required this.threadId,
    required this.currentUserId,
    required this.recepientId,
    required this.recepientName,
    required this.avatar,
    required this.unreadCount,
  });
}

class ThreadMessage {
  final String messageId;
  final String senderId;
  final String content;
  final String createdAt;
  final List<String>? media;
  final bool isRead;
  ThreadMessage({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.media,
    required this.isRead,
  });
  factory ThreadMessage.fromMap(Map<String, dynamic> m) {
    return ThreadMessage(
      messageId: m['message_id'] as String,
      senderId: m['sender_id'] as String,
      content: m['content'] as String,
      createdAt: m['created_at'] as String,
      media:
          (m['media'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList(),
      isRead: m['is_read'] as bool? ?? false,
    );
  }
}

// Screen
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.chatArgs});
  final ChatArgs chatArgs;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final messageCtrl = TextEditingController();
  final ValueNotifier<List<ThreadMessage>> chatMessages = ValueNotifier([]);
  final ScrollController scrollController = ScrollController();

  List<File> _selectedMedia = [];
  final Map<File, Future<Uint8List?>> _videoThumbnailFutures = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    context.read<ListMessagesCubit>().list(threadId: widget.chatArgs.threadId);
    if (widget.chatArgs.unreadCount > 0) {
      context.read<MarkReadCubit>().mark(threadId: widget.chatArgs.threadId);
    }
  }

  double getBottomInsets() {
    final double bottomInsets =
        MediaQuery.of(context).viewInsets.bottom -
        MediaQuery.of(context).viewPadding.bottom;
    return bottomInsets > 4 ? bottomInsets : 4;
  }

  _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Gap(2),
                CircleAvatar(
                  backgroundImage:
                      widget.chatArgs.avatar.isNotEmptyAndNotNull
                          ? CachedNetworkImageProvider(widget.chatArgs.avatar)
                          : null,
                  child:
                      widget.chatArgs.avatar.isEmptyOrNull
                          ? Text(widget.chatArgs.recepientName[0].toUpperCase())
                          : null,
                ),
                const Gap(12),
                Text(
                  widget.chatArgs.recepientName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ListMessagesCubit, ListMessagesState>(
            listener: (context, state) {
              if (state is ListMessagesSuccess) {
                final fetched =
                    (state.response as List)
                        .map(
                          (m) =>
                              ThreadMessage.fromMap(m as Map<String, dynamic>),
                        )
                        .toList();
                if (chatMessages.value.isEmpty) {
                  chatMessages.value = fetched;
                } else {
                  final existingIds =
                      chatMessages.value.map((t) => t.messageId).toSet();
                  final newOnes =
                      fetched
                          .where((t) => !existingIds.contains(t.messageId))
                          .toList();
                  if (newOnes.isNotEmpty) {
                    chatMessages.value = [...newOnes, ...chatMessages.value];
                  }
                }
              }
            },
          ),
          // On send
          BlocListener<SendMessageCubit, SendMessageState>(
            listener: (context, state) {
              if (state is SendMessageSuccess) {
                final m = state.response[0];
                final msg =
                    m is ThreadMessage
                        ? m
                        : ThreadMessage.fromMap(m as Map<String, dynamic>);
                chatMessages.value = [msg, ...chatMessages.value];
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
        ],
        child: BlocListener<MultiMediaCubit, MultiMediaState>(
          listener: (context, state) {
            if (state is MultiMediaSuccess) {
              _selectedMedia = state.response;
              _onChanged();
            }
          },
          child: Column(
            children: [
              // Messages
              Expanded(
                child: ValueListenableBuilder<List<ThreadMessage>>(
                  valueListenable: chatMessages,
                  builder: (context, messages, _) {
                    if (messages.isEmpty) {
                      return const Center(child: Text("No messages"));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final msg = messages[i];
                        final isMe =
                            msg.senderId == widget.chatArgs.currentUserId;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment:
                                isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 0.7.sw,
                                    minWidth: 0.2.sw,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isMe
                                            ? Colors.grey[300]
                                            : Theme.of(
                                              context,
                                            ).primaryColor.withAlpha(50),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(isMe ? 10 : 0),
                                      topRight: Radius.circular(isMe ? 0 : 10),
                                      bottomLeft: const Radius.circular(10),
                                      bottomRight: const Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (msg.media != null)
                                        msg.media!.isNotEmpty
                                            ? GalleryGrid(
                                              mediaUrls: msg.media!,
                                            ).pOnly(bottom: 4)
                                            : SizedBox.shrink(),
                                      SelectableText(
                                        msg.content,
                                        showCursor: true,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                      ),
                                      const Gap(4),
                                      Text(
                                        timeago.format(
                                          DateTime.parse(
                                            msg.createdAt,
                                          ).toLocal(),
                                          locale: 'en_short',
                                        ),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Input
              Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  left: 8,
                  right: 8,
                  bottom: getBottomInsets(),
                ),
                child:
                    _selectedMedia.isNotEmpty
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedMedia.length,
                                itemBuilder: (_, i) {
                                  final file = _selectedMedia[i];
                                  final isVideo = isVideoFile(file);

                                  if (isVideo &&
                                      !_videoThumbnailFutures.containsKey(
                                        file,
                                      )) {
                                    _videoThumbnailFutures[file] =
                                        generateVideoThumbnail(file.path);
                                  }

                                  return FutureBuilder<Uint8List?>(
                                    future:
                                        isVideo
                                            ? _videoThumbnailFutures[file]
                                            : Future.value(null),
                                    builder: (_, snapshot) {
                                      Widget mediaWidget;

                                      if (isVideo) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          mediaWidget = Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.black26,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        } else {
                                          final thumbnail = snapshot.data;
                                          mediaWidget =
                                              thumbnail != null
                                                  ? Image.memory(
                                                    thumbnail,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.black45,
                                                    child: const Icon(
                                                      Icons.videocam,
                                                      color: Colors.white70,
                                                    ),
                                                  );
                                        }
                                      } else {
                                        mediaWidget = Image.file(
                                          file,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        );
                                      }

                                      return Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              7,
                                            ),
                                            child: mediaWidget,
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap:
                                                  () => setState(() {
                                                    _videoThumbnailFutures
                                                        .remove(file);
                                                    _selectedMedia.removeAt(i);
                                                  }),
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ).pOnly(right: 8);
                                    },
                                  );
                                },
                              ),
                            ).pOnly(bottom: 16),
                            _inputSend(context),
                          ],
                        )
                        : _inputSend(context),
              ).p(4),
            ],
          ),
        ),
      ),
    );
  }

  Row _inputSend(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            context.read<MultiMediaCubit>().selectMedia();
          },
          child: Icon(Symbols.add_circle),
        ),
        Gap(8),
        Expanded(
          child: FormBuilderTextField(
            name: 'message',
            controller: messageCtrl,
            minLines: 1,
            maxLines: 3,
            onChanged: (v) {
              setState(() {});
            },
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Message',
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
        ),
        const Gap(8),
        BlocBuilder<SendMessageCubit, SendMessageState>(
          builder:
              (context, state) => switch (state) {
                SendMessageLoading() => context.isBusy(context),
                _ => IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed:
                      messageCtrl.text.trim().isEmpty
                          ? null
                          : () {
                            final txt = messageCtrl.text.trim();
                            messageCtrl.clear();
                            context.read<SendMessageCubit>().send(
                              threadId: widget.chatArgs.threadId,
                              content: txt,
                              mediaFiles: _selectedMedia,
                            );
                            _selectedMedia = [];
                          },
                ),
              },
        ),
      ],
    );
  }
}
