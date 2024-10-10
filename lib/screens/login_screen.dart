import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackme/screens/home_screen.dart';
import 'package:trackme/services/user_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  String email = '';
  String password = '';
  String name = '';
  String notificationTime = '';
  bool isRegistering = true;
  bool isLoading = false;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _notificationTimeFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _notificationTimeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Tracker - ${isRegistering ? 'Register' : 'Login'}'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
                SizedBox(height: 20),
                if (isLoading) CircularProgressIndicator(),
                if (!isLoading) ...[
                  _buildTextField(
                    focusNode: _emailFocusNode,
                    label: 'Email',
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    focusNode: _passwordFocusNode,
                    label: 'Password',
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  if (isRegistering) ...[
                    _buildTextField(
                      focusNode: _nameFocusNode,
                      label: 'Name',
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                    _buildTextField(
                      focusNode: _notificationTimeFocusNode,
                      label: 'Notification Time (HH:mm)',
                      onChanged: (value) {
                        setState(() {
                          notificationTime = value;
                        });
                      },
                      keyboardType: TextInputType.datetime,
                    ),
                  ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isRegistering ? _register : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text(isRegistering ? 'Register' : 'Login'),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isRegistering = !isRegistering;
                      });
                    },
                    child: Text(isRegistering
                        ? 'Already have an account? Login'
                        : 'New here? Register'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds a reusable text field with specific properties
  Widget _buildTextField({
    required FocusNode focusNode,
    required String label,
    required Function(String) onChanged,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  // Handles user registration logic
  Future<void> _register() async {
    if (_validateInputs()) {
      setState(() {
        isLoading = true;
      });
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _userService.addUser(
            userCredential.user!.uid, name, notificationTime);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? 'An error occurred');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Handles user login logic
  Future<void> _login() async {
    if (_validateInputs(isLogin: true)) {
      setState(() {
        isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? 'An error occurred');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Validates user input fields
  bool _validateInputs({bool isLogin = false}) {
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email and password are required.');
      return false;
    }
    if (!isLogin && (name.isEmpty || notificationTime.isEmpty)) {
      _showErrorDialog(
          'Name and notification time are required for registration.');
      return false;
    }
    return true;
  }

  // Displays an error dialog with a message
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
