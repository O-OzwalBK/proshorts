import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_shorts/views/signup/login_screen.dart';
import '../../constants.dart';
import '../../get/profile/get_profile_fetch.dart';
import '../../get/videos/get_all_videos.dart';
import '../home_screen/home_screen.dart';

const bool skipLogin = bool.fromEnvironment('SKIP_LOGIN', defaultValue: false);
const String devLoginEmail =
    String.fromEnvironment('DEV_LOGIN_EMAIL', defaultValue: '');
const String devLoginPassword =
    String.fromEnvironment('DEV_LOGIN_PASSWORD', defaultValue: '');

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () async {
      if (skipLogin &&
          devLoginEmail.isNotEmpty &&
          devLoginPassword.isNotEmpty) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: devLoginEmail,
            password: devLoginPassword,
          );
          await Get.put(FetchProfileController()).fetchMyProfile();
          Get.off(() => const HomeScreen());
          return;
        } catch (_) {
          // ignore dev sign-in failure and continue to regular flow
        }
      }

      if (FirebaseAuth.instance.currentUser != null) {
        Get.put(FetchProfileController()).fetchMyProfile();
        Get.off(() => const HomeScreen());
      } else {
        Get.off(() => LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Splash Screen"),
      ),
      body: const Center(
          child: CircleAvatar(
        radius: 100,
        backgroundImage: AssetImage(logo),
      )),
    );
  }
}
