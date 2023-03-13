import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/user_model.dart';
import 'package:todo_list/pages/register_page.dart';
import 'package:todo_list/services/auth_service.dart';
import 'package:todo_list/services/database_service.dart';
import 'package:todo_list/services/storage_service.dart';
import 'package:todo_list/widgets/auth_check.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/create_task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider<DatabaseService>(
          create: (context) => DatabaseService(
              uid: Provider.of<AuthService>(context).currentUser!.uid),
        ),
        ChangeNotifierProvider(create: (context) => StorageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organizador de tarefas',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheck(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) =>
            HomePage(user: Provider.of<AuthService>(context).currentUser!),
        '/create-task': (context) => const CreateTaskPage(),
      },
    );
  }
}
