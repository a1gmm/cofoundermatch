import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:uniapp/app/app_router.dart';
import 'package:uniapp/app/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return GlobalLoaderOverlay(
          overlayWidgetBuilder: (progress) {
            return Center(
              child: SizedBox.fromSize(
                size: const Size(32, 32),
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 4.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4f46e5)),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            );
          },
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routeInformationProvider: AppRouter.router.routeInformationProvider,
            routeInformationParser: AppRouter.router.routeInformationParser,
            routerDelegate: AppRouter.router.routerDelegate,
            title: 'Uniapp',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
          ),
        );
      },
    );
  }
}
