import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';

import './routes/app_pages.dart';
import './modules/splash_screen/binding/splash_binding.dart';
import './modules/splash_screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;
  
  runApp(MyApp(theme: theme));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  const MyApp({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyGo',
      theme: theme,
      home: const SplashScreen(),
      initialBinding: SplashBinding(),
      getPages: AppPages.pages,
    );
  }
}
