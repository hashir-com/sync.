import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  Future<User?> login(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  Future<void> logout() async => _auth.signOut();
}
