import 'package:earthquake_trackerr/controllers/onboarding_controller.dart';
import 'package:earthquake_trackerr/firebase_options.dart';
import 'package:earthquake_trackerr/mainscreen.dart';
import 'package:earthquake_trackerr/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vibration/vibration.dart';
import 'firebase_service.dart';
import 'package:earthquake_trackerr/pages/statistics_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:earthquake_trackerr/routes.dart';
import 'package:earthquake_trackerr/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully!');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  // Setting up Firebase Messaging and Notification Handler
  await setupFirebase();
  await GetStorage.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());

    // Retrieve values from localStorage
    final box = GetStorage();
    bool seenOnboarding = box.read('seen_onboarding') ?? false;
    String? userEmail = box.read('user_email');

    // Determine the initial route
    String initialRoute = seenOnboarding && userEmail != null
        ? MainScreen
            .route // Start from MainScreen if onboarding is seen and user is logged in
        : seenOnboarding
            ? LoginPage
                .route // Start from Login if onboarding is seen but no user email
            : OnboardingView.route; // Start from onboarding if not seen

    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Earthquake Alert App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MainScreen(),
          initialRoute: initialRoute,
          routes: getRoutes(),
        );
      },
    );
  }
}
