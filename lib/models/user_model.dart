import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  User? _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get user => _user;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      setIsLoading(true);
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      _logger.e('Failed to sign in with email and password', e);
      rethrow;
    } finally {
      setIsLoading(false);
    }
  }

  Future<void> setUser(User? user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    setUser(null);
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    setIsLoading(true);

    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = authResult.user!;
      setUser(user);
      setIsLoading(false);
    } on FirebaseAuthException catch (e) {
      setIsLoading(false);
      String errorMessage = 'Ocorreu um erro ao tentar criar a conta.';
      if (e.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'O email fornecido já está em uso por outra conta.';
      }
      throw errorMessage;
    } catch (e) {
      setIsLoading(false);
      throw 'Ocorreu um erro ao tentar criar a conta.';
    }
  }
}
