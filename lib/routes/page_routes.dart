import 'package:get/get.dart';
import '../views/home_page.dart';
import '../views/login_page.dart';
import '../views/signup_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  static final routes = [
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: signup, page: () => SignUpPage()),
    GetPage(name: home, page: () => HomePage()),
  ];
}
