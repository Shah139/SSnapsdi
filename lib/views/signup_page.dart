import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapsdi/controllers/auth_controller.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authController.signUp(emailController.text, passwordController.text),
              child: const Text("Sign Up"),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Already have an account? Login"),
            )
          ],
        ),
      ),
    );
  }
}
