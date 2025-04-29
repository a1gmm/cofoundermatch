import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/presentation/community/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({super.key, required this.member});
  final dynamic member;

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() {
    BlocProvider.of<MemberPostsCubit>(
      context,
    ).list(memberId: widget.member['user_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                widget.member['avatar'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Card(
                    margin: EdgeInsets.zero,
                    color: Theme.of(context).primaryColor,
                    child: Container(height: .3.sh),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.member['username'],
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
                ),
                Chip(
                  elevation: 0,
                  backgroundColor: Colors.green.withValues(alpha: 0.3),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity(horizontal: -3, vertical: -3),
                  label: Text(
                    'type',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
            Text(
              widget.member['bio'],
              maxLines: 2,
              style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
            ),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    children:
                        (widget.member['skills'] as List<dynamic>).map<Widget>((
                          e,
                        ) {
                          return Chip(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withAlpha(30),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity(
                              horizontal: -3,
                              vertical: -3,
                            ),
                            label: Text(
                              e.toString(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ).pOnly(right: 2);
                        }).toList(),
                  ),
                ),
              ],
            ),
            Gap(16),
            Text('Posts', style: Theme.of(context).textTheme.bodyLarge),
            BlocBuilder<MemberPostsCubit, MemberPostsState>(
              builder:
                  (context, state) => switch (state) {
                    MemberPostsSuccess() =>
                      state.response.isEmpty
                          ? Text('No posts').p(24).centered()
                          : ListView.builder(
                            itemCount: state.response.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return UserPostCard(
                                data: state.response[index],
                                deleted: null,
                              );
                            },
                          ),
                    _ => context.isBusy(context).p(24).centered(),
                  },
            ),
          ],
        ),
      ),
    );
  }
}
