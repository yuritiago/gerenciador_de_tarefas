import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AuthService extends GetxController with GetxServiceMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  User? _user;
  bool _isLoading = false;

  AuthService() {
    _authCheck();
  }

  bool get isLoading => _isLoading;
  User? get user => _user;

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      _user = (user == null) ? null : user;
      _isLoading = false;
      update();
    });
  }

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
    update();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    setUser(null);
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    update();
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
