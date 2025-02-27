
import 'package:flutter/material.dart';
import 'package:task_one_ict/feature/home/HomePage.dart';
import 'package:task_one_ict/widget/custom_button.dart';
import 'package:task_one_ict/widget/custom_input_field.dart';

import 'AuthApiService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    AuthService authService = AuthService();
    Map<String, dynamic> response = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response.containsKey('accessToken')) {
      print('Login Successful! Access Token: ${response['accessToken']}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      print('Login Failed: ${response['error']}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed! ${response['error']}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ONE ICT LTD",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomTextFromField(
                controller: _emailController,
                hintText: "User Name",
                obscureText: false,
                textInputType: TextInputType.text),
            const SizedBox(height: 20),
            CustomTextFromField(
                controller: _passwordController,
                hintText: "Password",
                obscureText: true,
                textInputType: TextInputType.text),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomElevatedButton(
                onPressed: () {
                  _login();
                },
                text: "Sign in",
                backgroundColor: Colors.green,
                textColor: Colors.white,
                borderColor: Colors.grey)
          ],
        ),
      ),
    );
  }
}