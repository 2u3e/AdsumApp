import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

/// Uygulama baslatma islemleri
/// Firebase, locale, orientasyon vb. ayarlar burada yapilir
Future<void> bootstrap() async {
  // Flutter engine hazir olana kadar bekle
  WidgetsFlutterBinding.ensureInitialized();

  // Turkce tarih formatlari
  await initializeDateFormatting('tr_TR', null);

  // Sadece dikey mod (portre)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar stili
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // TODO: Firebase baslatma
  // await Firebase.initializeApp();

  // Uygulamayi basalt
  runApp(
    const ProviderScope(
      child: AdsumApp(),
    ),
  );
}
