import 'package:flutter/material.dart';

class SignLanguageScreen extends StatefulWidget {
  const SignLanguageScreen({super.key});

  @override
  State<SignLanguageScreen> createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sign Language', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Text('Sign Language Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
