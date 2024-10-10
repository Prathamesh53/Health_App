import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TimerSetupScreen extends StatefulWidget {
  final String currentTime;

  TimerSetupScreen({required this.currentTime});

  @override
  _TimerSetupScreenState createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> {
  String notificationTime = '';

  @override
  void initState() {
    super.initState();
    notificationTime = widget.currentTime; // Set the current time
  }

  Future<void> _saveNotificationTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'notificationTime': notificationTime,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Notification Time')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration:
                  InputDecoration(labelText: 'Notification Time (HH:MM)'),
              keyboardType: TextInputType.datetime,
              onChanged: (value) {
                notificationTime = value; // Update the notification time
              },
            ),
            ElevatedButton(
              onPressed: _saveNotificationTime,
              child: Text('Save Time'),
            ),
          ],
        ),
      ),
    );
  }
}
