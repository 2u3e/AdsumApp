import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Ana uygulama widget'i
class AdsumApp extends ConsumerWidget {
  const AdsumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // Uygulama bilgileri
      title: 'ADSUM',
      debugShowCheckedModeBanner: false,

      // Tema
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Sistem ayarina gore otomatik

      // Lokalizasyon
      locale: const Locale('tr', 'TR'),

      // Router
      routerConfig: router,
    );
  }
}
