import 'package:flutter/material.dart';
import 'package:smartgreen/login.dart';
import 'package:smartgreen/cadastro.dart';
import 'package:smartgreen/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    );

  await FirebaseAppCheck.instance.activate(
    webProvider: null,
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
    );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGreen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      initialRoute: 'login.dart',
      routes: {
        'login.dart': (context) => LoginScreen(),
        'cadastro.dart': (context) => UserRegistrationPage(),
        'homepage.dart': (context) => HomePage(),
        },
    );
  }
}