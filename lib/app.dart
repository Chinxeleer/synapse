import 'package:flutter/material.dart';
import 'package:multilingual/features/sign_language/ui/sign_language_screen.dart';
import 'package:multilingual/features/text_translation/ui/text_translation_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      routes: {
        '/text-translation': (context) => const TextTranslationScreen(),
        '/sign-language': (context) => const SignLanguageScreen(),
      },
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Synapse',
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/text-translation');
                  },
                  child: const Text(
                    "Text Translation",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-language');
                  },
                  child: const Text(
                    "Sign Language",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
