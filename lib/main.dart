import 'package:flutter/material.dart';
import 'package:snapsdi/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:snapsdi/routes/page_routes.dart';
import 'dart:core';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zcdmnytnaugpwkpbevpx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpjZG1ueXRuYXVncHdrcGJldnB4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwMzkyNzUsImV4cCI6MjA1NzYxNTI3NX0.tn9zcoMRlN3LHSAGFpncbjOvhK7xPQ0ggJPB2YnHcEU'
  );
  Get.put(AuthController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
    );
  }
}
