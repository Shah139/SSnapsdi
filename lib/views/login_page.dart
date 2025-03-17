import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapsdi/controllers/auth_controller.dart';
import 'package:snapsdi/views/signup_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authController.login(emailController.text, passwordController.text),
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () => Get.to(SignUpPage()),
              child: const Text("Don't have an account? Sign up"),
            )
          ],
        ),
      ),
    );
  }
}
