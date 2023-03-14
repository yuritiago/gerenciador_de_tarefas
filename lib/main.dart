import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:todo_list/pages/register_page.dart';
import 'package:todo_list/services/auth_service.dart';
import 'package:todo_list/services/database_service.dart';
import 'package:todo_list/services/storage_service.dart';
import 'package:todo_list/widgets/auth_check.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/create_task_page.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.lazyPut<AuthService>(() => AuthService());
  Get.put<DatabaseService>(DatabaseService(uid: ""));
  Get.put<StorageService>(StorageService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Organizador de tarefas',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const AuthCheck()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(
          name: '/home',
          page: () => HomePage(
            user: Get.find<AuthService>().user!,
          ),
        ),
        GetPage(name: '/create-task', page: () => const CreateTaskPage()),
      ],
    );
  }
}
