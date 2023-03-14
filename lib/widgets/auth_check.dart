import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:todo_list/pages/login_page.dart';

import '../pages/home_page.dart';
import '../services/auth_service.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  AuthCheckState createState() => AuthCheckState();
}

class AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthService>(
      builder: (auth) {
        if (auth.isLoading) {
          return loading();
        } else if (auth.user == null) {
          return const LoginPage();
        } else {
          return HomePage(
            user: FirebaseAuth.instance.currentUser!,
          );
        }
      },
    );
  }
}

loading() {
  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}
