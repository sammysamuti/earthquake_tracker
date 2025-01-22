import 'package:earthquake_trackerr/auth/login.dart';
import 'package:earthquake_trackerr/auth/register.dart';
import 'package:earthquake_trackerr/pages/home_page.dart';
import 'package:earthquake_trackerr/pages/onboarding_page.dart';
import 'package:earthquake_trackerr/mainscreen.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    LoginPage.route: (context) => LoginPage(),
    RegisterPage.route: (context) => RegisterPage(),
    HomePage.route: (context) => HomePage(),
    OnboardingView.route: (context) => OnboardingView(),
    MainScreen.route: (context) => MainScreen(),
  };
}
