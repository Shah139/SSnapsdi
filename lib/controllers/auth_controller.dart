import 'package:get/get.dart';
import 'package:snapsdi/views/home_page.dart';
import 'package:snapsdi/views/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((event) {
      currentUser.value = event.session?.user;
    });
  }

  Future<void> signUp(String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(email: email, password: password);
      if (res.user != null) {
        Get.snackbar("Success", "Account Created!");
        Get.to(HomePage());
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (res.user != null) {
        Get.snackbar("Success", "Login Successful!");
        Get.to(HomePage());
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    Get.to(LoginPage());
  }
}
