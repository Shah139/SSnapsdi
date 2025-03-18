import 'package:get/get.dart';
import '../controllers/comment_controller.dart';

class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommentController>(() => CommentController());
  }
}
