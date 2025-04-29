import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/presentation/community/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() {
    BlocProvider.of<ListCommunityPostsCubit>(context).list();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text('Community').onTap(() => _initData())),
      body: BlocBuilder<ListCommunityPostsCubit, ListCommunityPostsState>(
        builder:
            (context, state) => switch (state) {
              ListCommunityPostsSuccess() =>
                state.response.isEmpty
                    ? Text('No posts').p(24).centered()
                    : RefreshIndicator.adaptive(
                      onRefresh: () async => _initData(),
                      child: ListView.builder(
                        itemCount: state.response.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        itemBuilder: (context, index) {
                          return PostCard(data: state.response[index]);
                        },
                      ),
                    ),
              _ => context.isBusy(context).p(24).centered(),
            },
      ),
    );
  }
}
