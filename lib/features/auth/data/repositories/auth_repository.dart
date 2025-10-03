import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_event/features/auth/domain/entities/user_entitiy.dart';
import 'package:sync_event/features/auth/domain/repo/auth_repo.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this.dataSource, {FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final user = await dataSource.signUpWithEmail(email, password);
    if (user != null) {
      await dataSource.updateUserName(name);
      // Store user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return UserModel.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<UserEntity?> loginWithEmail(String email, String password) async {
    final user = await dataSource.loginWithEmail(email, password);
    return user != null ? UserModel.fromFirebase(user) : null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<bool> signInWithGoogle(bool forceAccountChooser) async {
    return await dataSource.signInWithGoogle(forceAccountChooser);
  }

  @override
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
    Function(UserEntity) verificationCompleted,
    Function(String) verificationFailed,
  ) async {
    await dataSource.verifyPhoneNumber(
      phoneNumber,
      codeSent,
      codeAutoRetrievalTimeout,
      (credential) async {
        final user = await dataSource.signInWithCredential(credential);
        if (user != null) {
          verificationCompleted(UserModel.fromFirebase(user));
        } else {
          verificationFailed('Failed to sign in with credential');
        }
      },
      (e) => verificationFailed(e.message ?? 'Verification failed'),
    );
  }

  @override
  Future<UserEntity?> verifyOtp(String otp) async {
    final user = await dataSource.verifyOtp(otp);
    return user != null ? UserModel.fromFirebase(user) : null;
  }

  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }

  // New method to get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }
}