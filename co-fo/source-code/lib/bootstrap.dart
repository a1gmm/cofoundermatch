import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    final logData = {
      'event': 'onChange',
      'bloc': bloc.runtimeType.toString(),
      'currentState': change.currentState.toString(),
      'nextState': change.nextState.toString(),
    };

    log(jsonEncode(logData));
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    final logData = {
      'event': 'onError',
      'bloc': bloc.runtimeType.toString(),
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
    };

    log(jsonEncode(logData));

    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    if (!details.exceptionAsString().contains('PointerAddedEvent')) {
      log(details.exceptionAsString(), stackTrace: details.stack);
    }
  };

  Bloc.observer = const AppBlocObserver();

  runApp(await builder());
}
