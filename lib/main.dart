import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_practical_task_etech/screens/user/user_list_screen.dart';
import 'package:flutter_practical_task_etech/usage/app_initial_biding_screen.dart';
import 'package:get/get.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'User Management',
      debugShowCheckedModeBanner: false,
      enableLog: !kReleaseMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialBinding: AppInitialBinding(),
      home: UserListScreen(),
    );
  }
}

