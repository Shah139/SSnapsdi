import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
