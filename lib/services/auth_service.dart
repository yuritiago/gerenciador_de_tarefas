import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AuthService extends GetxController with GetxServiceMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;
  final Logger _logger = Logger();

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      update();
    });
  }

  User? get currentUser => usuario;

  Future<User?> signin(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        _logger.i('User ${user.uid} signed in');
        return user;
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Error signing in: ${e.message}');
      return null;
    }
    return null;
  }
}
