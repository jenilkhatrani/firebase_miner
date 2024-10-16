import 'package:chat_app/views/pages/chat_page.dart';
import 'package:chat_app/views/pages/home_page.dart';
import 'package:chat_app/views/pages/intro_page.dart';
import 'package:chat_app/views/pages/sign_in_page.dart';
import 'package:chat_app/views/pages/sign_up_page.dart';
import 'package:chat_app/views/pages/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool res = prefs.getBool('isIntroScreenVisited') ?? false;
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: (res == false) ? '/splash_page' : '/sign_in_page',
      getPages: [
        GetPage(name: '/splash_page', page: () => SplashPage()),
        GetPage(name: '/intro_page', page: () => IntroScreen()),
        GetPage(name: '/home_page', page: () => HomePage()),
        GetPage(name: '/sign_up_page', page: () => SignUpPage()),
        GetPage(name: '/sign_in_page', page: () => SignInPage()),
        GetPage(name: '/chat_page', page: () => ChatPage()),
      ],
    ),
  );
}
