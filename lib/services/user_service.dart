import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //method to add user
  Future<void> addUser(
      String userId, String name, String notificationTime) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'notificationTime': notificationTime,
      });
    } catch (e) {
      // Handle error if necessary
      print('Error adding user: $e');
    }
  }

  // Method to add a weight record
  Future<void> addWeightRecord(String userId, double weight) async {
    final weightRecord = {
      'weight': weight,
      'date': DateTime.now().toIso8601String(),
    };

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('weightRecords')
        .add(weightRecord);
  }

  // Method to fetch weight records
  Future<List<Map<String, dynamic>>> getWeightRecords(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('weightRecords')
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Method to get user document
  Future<DocumentSnapshot> getUser(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // Method to save notification time
  Future<void> saveNotificationTime(
      String userId, String notificationTime) async {
    await _firestore.collection('users').doc(userId).update({
      'notificationTime': notificationTime,
    });
  }
}
