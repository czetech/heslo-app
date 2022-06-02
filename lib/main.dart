import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'screen_faq.dart';
import 'screen_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the default configuration.
  await GlobalConfiguration().loadFromPath('config/default.json');

  // Optionally update the configuration using the app's local configuration.
  try {
    await GlobalConfiguration().loadFromPath('config/app.json');
  } catch (e) {}

  await PackageInfo.fromPlatform();

  runApp(
    MaterialApp(
      routes: {
        '/': (context) => MainScreen(),
        '/faq': (context) => FaqScreen(),
      },
      initialRoute: '/',
      title: "Heslo",
      theme: ThemeData(
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 24),
        ),
      ),
    ),
  );
}
