import 'package:flutter/material.dart';
import 'UI/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'UI/splash.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'helper/database_helper.dart';
import 'providers/chart_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ApiService apiService = ApiService();
  apiService.startListeningToConnectivity();
  NotificationService.init();
  await DatabaseHelper().database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChartDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      theme: ThemeData(
        fontFamily: 'Kanit',
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: AuthService().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.data == true) {
              return const SplashScreen();
            } else {
              return const LoginScreen();
            }
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
