import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

// Initialize local notifications
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Function to request permissions and set up Firebase messaging
Future<void> setupFirebase() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission for iOS
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("Notification permission granted");
  } else {
    print("Notification permission denied");
  }

  // Initialize local notifications
  await _initializeLocalNotifications();

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Message received: ${message.notification?.title}");

    if (message.notification != null) {
      // Trigger vibration and display the notification
      triggerVibration();
      showNotification(message.notification?.title ?? 'Earthquake Alert',
          message.notification?.body ?? 'Earthquake detected nearby!');
    }
  });

  // Handle background notifications
  FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
    print("Background message received: ${message.notification?.title}");
    // Handle the message and trigger vibration
    triggerVibration();
    showNotification(message.notification?.title ?? 'Earthquake Alert',
        message.notification?.body ?? 'Earthquake detected nearby!');
  });
}

// Initialize local notifications
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Function to trigger phone vibration
void triggerVibration() {
  if (Vibration.hasVibrator() != null) {
    Vibration.vibrate(duration: 1000); // Vibrates for 1 second
  }
}

// Function to display the notification locally
Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'earthquake_channel_id',
    'Earthquake Alerts',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0, // notification ID
    title,
    body,
    platformDetails,
  );
}
