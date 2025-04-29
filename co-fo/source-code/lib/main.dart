import 'package:flutter/material.dart';
import 'package:uniapp/app/app.dart';
import 'package:uniapp/app/app_init.dart';
import 'package:uniapp/bootstrap.dart';
import 'package:uniapp/core/injection.dart';

import 'app/utils/extensions/orientation_extension.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await AppInitialization.I.initApp();
  await OrientationExtension.lockVertical();
  await bootstrap(() => const App());
}
