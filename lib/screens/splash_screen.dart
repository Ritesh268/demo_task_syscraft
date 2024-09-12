import 'package:demo_task_syscraft/constants/assets_path.dart';
import 'package:demo_task_syscraft/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(
      const Duration(seconds: 5),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      ),
    );

    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  AssetPath.backgroundImage,
                ),
                fit: BoxFit.fill),
          ),
          child: Center(
            child: Image.asset(
              AssetPath.logo,
              fit: BoxFit.fill,
            ),
          )),
    );
  }
}
