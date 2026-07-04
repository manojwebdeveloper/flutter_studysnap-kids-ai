import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'core/config/app_env.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

final log = Logger(
  printer: PrettyPrinter(methodCount: 0, printEmojis: true),
  level: Level.debug,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env before anything else
  await AppEnv.load();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar, dark icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  log.i('StudySnap Kids AI starting — env: ${AppEnv.appEnv}');

  runApp(
    const ProviderScope(
      child: StudySnapApp(),
    ),
  );
}

class StudySnapApp extends ConsumerWidget {
  const StudySnapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'StudySnap Kids AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
