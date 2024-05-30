import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letters/auth/auth_gate.dart';
import 'package:letters/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("4b3b447f-4915-4439-b3d8-0da767e76e77");
  OneSignal.Notifications.requestPermission(true);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: FlutterSplashScreen.gif(
        gifPath: 'assets/splash.gif',
        gifWidth: width / 1.2,
        gifHeight: height,
        backgroundColor: Colors.black,
        duration: const Duration(milliseconds: 3000),
        nextScreen: const AuthGate(),
      ),
    );
  }
}
