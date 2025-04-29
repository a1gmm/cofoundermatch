import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/data/imports.dart';
import 'package:uniapp/presentation/auth/imports.dart';
import 'package:uniapp/presentation/community/imports.dart';
import 'package:uniapp/presentation/profile/imports.dart';
import 'package:uniapp/presentation/widgets/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final CurrentUser? user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late CurrentUser user;
  String avatar = '';

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() {
    BlocProvider.of<ListUserPostsCubit>(context).list();
    user = widget.user!;
    avatar = user.avatar;
    _onChanged();
  }

  _pickImage() => context.read<MediaPickerCubit>().selectImage();

  _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SignOutCubit, SignOutState>(
      listener: (context, state) {
        if (state is SignOutSuccess) {
          context.loaderOverlay.hide();
          context.pushReplacementNamed(AppRouter.signinScreen);
        }
        if (state is SignOutError) {}
        if (state is SignOutLoading) {
          context.loaderOverlay.show();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: [
            CustomBottomSheet(
              text: Icon(Symbols.settings),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Gap(8),
                  ListTile(
                    leading: Icon(Symbols.logout),
                    title: Text('Sign out'),
                    onTap: () {
                      context.read<SignOutCubit>().signout();
                    },
                  ),
                ],
              ),
            ),
            Gap(8),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocListener<MediaPickerCubit, MediaPickerState>(
                      listener: (context, state) {
                        if (state is MediaPickerSuccess) {
                          context.read<UploadImageCubit>().upload(
                            userId: user.userId,
                            img: state.image,
                          );
                        }
                      },
                      child: BlocConsumer<UploadImageCubit, UploadImageState>(
                        listener: (context, state) {
                          if (state is UploadImageSuccess) {
                            avatar = state.response;
                            _onChanged();
                          }
                        },
                        builder:
                            (context, state) => switch (state) {
                              UploadImageLoading() => Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  _avatar(context),
                                  Positioned(
                                    left: 40,
                                    child: context.isBusy(context),
                                  ),
                                ],
                              ),

                              _ => _avatar(context),
                            },
                      ),
                    ),
                    Gap(8),
                    Text(
                      user.bio,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(color: Colors.grey[600]),
                    ),
                    Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            children:
                                user.skills
                                    .map(
                                      (e) => Chip(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.3),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity(
                                          horizontal: -3,
                                          vertical: -3,
                                        ),
                                        label: Text(
                                          e,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ).pSymmetric(h: 2),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).p(8),
              ),
              Gap(16),
              Text(
                'My posts',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
              ),
              BlocBuilder<ListUserPostsCubit, ListUserPostsState>(
                builder:
                    (context, state) => switch (state) {
                      ListUserPostsSuccess() =>
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
                                  deleted: (v) {
                                    // TODO:
                                    BlocProvider.of<ListUserPostsCubit>(
                                      context,
                                    ).list();
                                  },
                                );
                              },
                            ),
                      _ => context.isBusy(context).p(24).centered(),
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _avatar(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        avatar.isEmptyOrNull
            ? GestureDetector(
              onTap: () => _pickImage(),
              child: SizedBox(
                height: 100,
                width: 100,
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surface,
                  child: Icon(Symbols.camera_alt_rounded, color: Colors.grey),
                ),
              ),
            )
            : GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => Material(
                        type: MaterialType.transparency,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: .8.sh,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(imageUrl: avatar),
                                ),
                              ),
                            ).pSymmetric(h: 8),
                            Gap(16),
                            OutlinedButton(
                              onPressed: () {
                                context.pop();
                                _pickImage();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white, width: 1),
                              ),
                              child: Text(
                                'Update',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: avatar,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => SizedBox(
                        height: 100,
                        width: 100,
                        child:
                            Card(
                              elevation: 0,
                              color: Theme.of(context).colorScheme.surface,
                            ).shimmer(),
                      ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(user.username, style: Theme.of(context).textTheme.titleLarge),
            Text(
              user.title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]),
            ),
            Gap(8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.comfortable,
              ),
              onPressed: () {
                context
                    .pushNamed(AppRouter.updateProfileScreen, extra: user)
                    .then((v) {
                      if (v != null) {
                        final updatedUser = v as CurrentUser;
                        user = updatedUser;
                        _onChanged();
                      }
                    });
              },
              child: Text('Edit profile'),
            ),
          ],
        ),
      ],
    );
  }
}
