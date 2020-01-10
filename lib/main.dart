import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vistocode/screens/auth/login.dart';
import 'package:vistocode/screens/auth/register.dart';
import 'package:vistocode/screens/main/active.dart';
import 'package:vistocode/screens/main/generate.dart';
import 'package:vistocode/screens/main/home.dart';
import 'package:vistocode/screens/main/notification.dart';
import 'package:vistocode/screens/main/visitors.dart';
import 'package:vistocode/screens/main/welcome.dart';
import 'package:vistocode/screens/password/change.dart';
import 'package:vistocode/screens/password/reset.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


void main() {
   flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  runZoned(() {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
  ]).then((_){
      runApp(MyApp());
  });

  }, onError: (dynamic error, dynamic stack) {
    print(error);
    print(stack);
  });

  }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vistocode',
      theme: ThemeData(
        fontFamily: 'Comfortaa',
        primaryColor: Color(0xFFFDA203),
        accentColor: Color(0xFF8934FF)
      ),
      home: LoginScreen(),
      routes: <String, WidgetBuilder>{
        '/LoginScreen': (BuildContext context) => new LoginScreen(),
        '/ResetPasswordScreen': (BuildContext context) => new ResetPasswordScreen(),
        '/RegisterScreen': (BuildContext context) => new RegisterScreen(),
        '/ChangePasswordScreen': (BuildContext context) => new ChangePasswordScreen(),
        '/WelcomeScreen': (BuildContext context) => new WelcomeScreen(),
        '/HomeScreen': (BuildContext context) => new HomeScreen(),
        '/GenerateScreen': (BuildContext context) => new GenerateScreen(),
        '/ActiveVisitorsScreen': (BuildContext context) => new ActiveVisitorsScreen(),
        '/VisitorsListScreen': (BuildContext context) => new VisitorsListScreen(),
        '/NotificationScreen': (BuildContext context) => new NotificationScreen(''),
      },
    );
  }
}
