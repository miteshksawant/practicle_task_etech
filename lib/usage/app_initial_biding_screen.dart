import 'package:flutter_practical_task_etech/screens/user/controller/user_controller.dart';
import 'package:get/get.dart';

class AppInitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController());
  }
}
