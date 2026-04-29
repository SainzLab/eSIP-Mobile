import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'models/pocketbase_service.dart';
import 'login_screen.dart'; 
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PocketBaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'eSIP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2563EB),
        useMaterial3: true,
      ),
      
      home: PocketBaseService.pb.authStore.isValid 
          ? const MainScreen() 
          : const LoginScreen(),
    );
  }
}