import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackme/screens/login_screen.dart';
import 'package:trackme/services/notification_services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Request notification permission
  await _requestNotificationPermission();

  final NotificationService notificationService = NotificationService();
  await notificationService.initialize(); // Initialize notifications

  runApp(MyApp());
}

// Function to request notification permission
Future<void> _requestNotificationPermission() async {
  if (await Permission.notification.request().isGranted) {
    // Permission granted, you can proceed to show notifications
    print("Notification permission granted");
  } else {
    // Permission denied, handle accordingly
    print("Notification permission denied");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weight Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Start with the LoginScreen
    );
  }
}
