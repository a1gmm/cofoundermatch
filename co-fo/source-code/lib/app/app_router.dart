import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniapp/data/imports.dart';
import 'package:uniapp/presentation/auth/imports.dart';
import 'package:uniapp/presentation/bottom_nav/bottom_nav.dart';
import 'package:uniapp/presentation/bottom_nav/imports.dart';
import 'package:uniapp/presentation/chat/imports.dart';
import 'package:uniapp/presentation/community/imports.dart';
import 'package:uniapp/presentation/profile/imports.dart';

class AppRouter {
  AppRouter._privateConstructor() {
    _initialize();
  }

  factory AppRouter.init() {
    return _instance;
  }
  //
  static final AppRouter _instance = AppRouter._privateConstructor();
  static late GoRouter router;
  //
  static const _initialLocation = '/signin';
  static const _signin = '/signin';
  static const _signup = '/signup';
  static const _completeProfile = '/completeProfile';
  static const _bottomMenu = '/bottomNav';
  static const _updateProfile = 'updateProfile';
  static const _chatDetail = 'chatDetail';
  static const _memberDetail = 'memberDetail';

  //
  static String get signinScreen => 'SigninScreen';
  static String get signupScreen => 'SignupScreen';
  static String get completeProfileScreen => 'CompleteProfileScreen';
  static String get bottomMenuScreen => 'BottomMenu';
  static String get updateProfileScreen => 'UpdateProfileScreen';
  static String get chatDetailScreen => 'ChatDetailScreen';
  static String get memberDetailScreen => 'MemberDetailScreen';
  //
  void _initialize({String initialLocation = _initialLocation}) {
    router = GoRouter(
      initialLocation: initialLocation,
      routes: <GoRoute>[
        GoRoute(
          path: _signin,
          name: signinScreen,
          builder:
              (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => SignInCubit()),
                  BlocProvider(create: (context) => ReadProfileCubit()),
                ],
                child: SigninScreen(),
              ),
        ),
        GoRoute(
          path: _signup,
          name: signupScreen,
          builder:
              (context, state) => BlocProvider(
                create: (context) => SignUpCubit(),
                child: SignupScreen(),
              ),
        ),
        GoRoute(
          path: _completeProfile,
          name: completeProfileScreen,
          builder:
              (context, state) => BlocProvider(
                create: (context) => CompleteProfileCubit(),
                child: CompleteProfileScreen(),
              ),
        ),
        GoRoute(
          path: _bottomMenu,
          name: bottomMenuScreen,
          builder:
              (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => SignOutCubit()),
                  BlocProvider(create: (context) => ReadProfileCubit()),
                  BlocProvider(create: (context) => ListUserPostsCubit()),
                  BlocProvider(create: (context) => LikePostCubit()),
                  BlocProvider(create: (context) => ListCommunityPostsCubit()),
                  BlocProvider(create: (context) => MediaPickerCubit()),
                  BlocProvider(create: (context) => VideoPickerCubit()),
                  BlocProvider(create: (context) => UploadImageCubit()),
                  BlocProvider(create: (context) => SwipeMembersCubit()),
                  BlocProvider(create: (context) => ListChatsCubit()),
                  BlocProvider(create: (context) => DeletePostCubit()),
                ],
                child: BottomNav(),
              ),
          routes: [
            GoRoute(
              path: _updateProfile,
              name: updateProfileScreen,
              builder:
                  (context, state) => BlocProvider(
                    create: (context) => UpdateProfileCubit(),
                    child: UpdateProfileScreen(
                      user: state.extra as CurrentUser,
                    ),
                  ),
            ),
            GoRoute(
              path: _chatDetail,
              name: chatDetailScreen,
              builder:
                  (context, state) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (context) => ListMessagesCubit()),
                      BlocProvider(create: (context) => MarkReadCubit()),
                      BlocProvider(create: (context) => SendMessageCubit()),
                      BlocProvider(create: (context) => MultiMediaCubit()),
                    ],
                    child: ChatDetailScreen(chatArgs: state.extra as ChatArgs),
                  ),
            ),
            GoRoute(
              path: _memberDetail,
              name: memberDetailScreen,
              pageBuilder:
                  (context, state) => MaterialPage(
                    fullscreenDialog: true,
                    child: BlocProvider(
                      create: (context) => MemberPostsCubit(),
                      child: MemberDetailScreen(member: state.extra),
                    ),
                  ),
            ),
          ],
        ),
      ],
      //
      redirect: (BuildContext context, GoRouterState state) async {
        final sb = Supabase.instance;
        final loginLoc = state.namedLocation(signinScreen);
        final signupLoc = state.namedLocation(signupScreen);
        final bottomNavLoc = state.namedLocation(bottomMenuScreen);

        if (state.matchedLocation == signupLoc) {
          return null;
        }
        if (sb.client.auth.currentSession == null) {
          return state.matchedLocation == loginLoc ? null : loginLoc;
        }

        if (state.matchedLocation == loginLoc) {
          return bottomNavLoc;
        }
        return null;
      },
    );
  }
}
