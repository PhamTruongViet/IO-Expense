import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:io_expense_data/services/notification_service.dart';
import 'package:lottie/lottie.dart';
import 'package:io_expense_data/UI/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  final Completer<void> _permissionCompleter = Completer<void>();

  @override
  void initState() {
    super.initState();
    _checkAndShowNotificationPermissionDialog();
    _permissionCompleter.future.then((_) {
      _timer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndShowNotificationPermissionDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAskedPermission =
        prefs.getBool('hasAskedNotificationPermission') ?? false;

    if (!hasAskedPermission) {
      await Future.delayed(const Duration(seconds: 1));
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Notification Permission'),
            content: const Text(
                'We would like to send you notifications. Do you allow it?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestNotificationPermission();
                },
                child: const Text('Allow'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _permissionCompleter.complete();
                },
                child: const Text('Deny'),
              ),
            ],
          );
        },
      );
    } else {
      _permissionCompleter.complete();
    }
  }

  Future<void> _requestNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (isAllowed) {
      NotificationService.init();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAskedNotificationPermission', true);
    _permissionCompleter.complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset('assets/splash_icon.json'),
          ],
        ),
      ),
    );
  }
}
