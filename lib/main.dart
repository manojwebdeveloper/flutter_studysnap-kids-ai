import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Fresh-install guard: on the very first launch, wipe any leftover storage
  // (e.g. data restored from a previous install) so the app opens completely
  // clean with onboarding — no stale children or flags.
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('app_initialized')) {
    await prefs.clear();
    await prefs.setBool('app_initialized', true);
  }

  // Read the onboarding / PIN flags once so the router redirect never has to
  // touch storage on every navigation (which could bounce mid-flow).
  await initStartupFlags();

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
      // Respect the user's system font size, but clamp the range so very
      // large Dynamic Type (iOS) / font scale (Android) can't break the
      // fixed kid-mode layouts. Standard accessibility practice.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
