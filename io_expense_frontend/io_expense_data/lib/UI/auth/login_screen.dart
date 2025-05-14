import 'package:flutter/material.dart';
import 'package:io_expense_data/UI/home.dart';
import 'package:io_expense_data/services/auth_service.dart';
import 'package:io_expense_data/UI/auth/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    try {
      final userId = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      print(userId);
      print(_emailController.text);
      print(_passwordController.text);
      print(_passwordController.text);

      if (userId != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thất bại')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Đăng nhập'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SignupScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var tween = Tween<Offset>(
                          begin: const Offset(1.0, 0.0), end: Offset.zero);
                      var curveTween = CurveTween(curve: Curves.ease);

                      return SlideTransition(
                        position: animation.drive(curveTween).drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: const Text('Chưa có tài khoản? Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}
