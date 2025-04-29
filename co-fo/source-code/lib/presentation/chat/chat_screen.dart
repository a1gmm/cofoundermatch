import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/data/imports.dart';
import 'package:uniapp/presentation/chat/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});
  final CurrentUser? user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<dynamic> threads = [];
  final sb = Supabase.instance.client;

  @override
  void initState() {
    _initData();

    sb
        .channel('chat_threads_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_threads',
          callback: (payload) {
            _initData();
          },
        )
        .subscribe();

    sb
        .channel('chat_messages_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            _initData();
          },
        )
        .subscribe();
    super.initState();
  }

  _initData() {
    BlocProvider.of<ListChatsCubit>(context).list();
  }

  _onChanged() => setState(() {});

  @override
  void dispose() {
    sb.removeAllChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: BlocConsumer<ListChatsCubit, ListChatsState>(
        listener: (context, state) {
          if (state is ListChatsSuccess) {
            final newThreads = state.response;
            final Map<String, Map<String, dynamic>> threadMap = {
              for (var thread in threads) thread['thread_id']: thread,
            };

            for (var newThread in newThreads) {
              threadMap[newThread['thread_id']] = newThread;
            }

            threads = threadMap.values.toList();
            _onChanged();
          }
        },
        builder:
            (context, state) => switch (state) {
              ListChatsSuccess() =>
                threads.isEmpty
                    ? Text('No chats').centered()
                    : ListView.separated(
                      itemBuilder: (context, index) {
                        return ChatThreadCard(
                          threads: threads[index],
                          user: widget.user!,
                        );
                      },
                      separatorBuilder:
                          (BuildContext context, int index) => const Divider(),
                      itemCount: threads.length,
                    ),
              _ => context.isBusy(context).centered(),
            },
      ),
    );
  }
}

class ChatThreadCard extends StatefulWidget {
  const ChatThreadCard({super.key, required this.threads, required this.user});
  final dynamic threads;
  final CurrentUser user;

  @override
  State<ChatThreadCard> createState() => _ChatThreadCardState();
}

class _ChatThreadCardState extends State<ChatThreadCard> {
  int unreadCount = 0;
  String lastMessage = '';

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() {
    unreadCount = widget.threads['unread_count'] ?? 0;
    lastMessage = widget.threads['last_message'] ?? '';
    _onChanged();
  }

  _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context
            .pushNamed(
              AppRouter.chatDetailScreen,
              extra: ChatArgs(
                threadId: widget.threads['thread_id'],
                currentUserId: widget.user.userId,
                recepientId: widget.threads['other_user_id'],
                recepientName: widget.threads['username'],
                avatar: widget.threads['avatar'],
                unreadCount: int.parse(
                  widget.threads['unread_count'].toString(),
                ),
              ),
            )
            .then((v) {
              unreadCount = 0;
            });
      },
      visualDensity: VisualDensity.compact,
      leading: CircleAvatar(
        backgroundImage:
            widget.threads['avatar'] != ''
                ? CachedNetworkImageProvider(widget.threads['avatar'])
                : null,
        child:
            widget.threads['avatar'] == ''
                ? Text(widget.threads['username'][0].toString().toUpperCase())
                : null,
      ),
      title: Text(widget.threads['username']),
      subtitle: Text(
        lastMessage,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing:
          widget.threads['last_sent_at'] == null
              ? null
              : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  Text(
                    timeago.format(
                      DateTime.parse(widget.threads['last_sent_at']).toLocal(),
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                  ),
                  unreadCount <= 0
                      ? SizedBox.shrink()
                      : Badge.count(count: widget.threads['unread_count']),
                ],
              ),
    );
  }
}
