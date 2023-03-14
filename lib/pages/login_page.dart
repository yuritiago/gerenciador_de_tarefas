import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password;

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final userModel = Get.find<UserModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? 'Email não pode ser vazio' : null,
                onChanged: (value) => _email = value.trim(),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? 'Senha não pode ser vazia' : null,
                onChanged: (value) => _password = value.trim(),
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              const SizedBox(height: 32.0),
              userModel.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          userModel.setIsLoading(true);
                          User? user = await authService.signin(
                              email: _email, password: _password);
                          if (user != null) {
                            userModel.setUser(user);
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(context, '/tasks');
                          } else {
                            userModel.setIsLoading(false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Falha na autenticação'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Entrar'),
                    ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
