import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trackme/screens/login_screen.dart';
import 'package:trackme/screens/timer_setup_screen.dart';
import 'package:trackme/services/notification_services.dart';
import 'package:trackme/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService userService = UserService();
  final NotificationService notificationService = NotificationService();
  List<Map<String, dynamic>> weightRecords = [];
  double newWeight = 0;
  String notificationTime = '';

  @override
  void initState() {
    super.initState();
    _fetchWeightRecords(); // Fetches the user's weight records from Firestore
    _fetchNotificationTime(); // Retrieves the user's notification time
    notificationService.initialize(); // Initializes the notification service
  }

  // Fetches weight records for the current user from Firestore
  Future<void> _fetchWeightRecords() async {
    final user = _auth.currentUser;
    if (user != null) {
      weightRecords = await userService.getWeightRecords(user.uid);
      setState(() {}); // Updates the UI with the fetched records
    }
  }

  // Retrieves the user's notification time from Firestore
  Future<void> _fetchNotificationTime() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await userService.getUser(user.uid);
      setState(() {
        notificationTime =
            userDoc['notificationTime']; // Sets the notification time
      });
    }
  }

  // Adds a new weight record for the current user and schedules a notification
  Future<void> _addWeightRecord() async {
    final user = _auth.currentUser;
    if (user != null) {
      await userService.addWeightRecord(user.uid, newWeight);
      newWeight = 0; // Resets the weight input
      await _fetchWeightRecords(); // Refreshes the weight records

      // Schedules a daily notification if notification time is set
      if (notificationTime.isNotEmpty) {
        final timeParts = notificationTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        await notificationService.scheduleDailyNotification(
          Time(hour, minute),
          'Time to weigh!',
          'Don’t forget to record your weight!',
        );
      }
    }
  }

  // Navigates to the TimerSetupScreen to change the notification time
  Future<void> _changeNotificationTime() async {
    final user = _auth.currentUser;
    if (user != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimerSetupScreen(currentTime: notificationTime),
        ),
      );
      await _fetchNotificationTime(); // Fetches updated notification time
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut(); // Signs out the user
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100], // Sets a light background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Enter your weight',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        newWeight =
                            double.tryParse(value) ?? 0; // Updates weight input
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addWeightRecord,
                      child: Text('Add Weight Record'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Previous Weight Records',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: weightRecords.length,
                itemBuilder: (context, index) {
                  final record = weightRecords[index];
                  final dateTime = DateTime.parse(record['date']).toLocal();

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weight: ${record['weight']} kg',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Date: ${dateTime.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Time: ${dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changeNotificationTime,
              child: Text('Change Notification Time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
