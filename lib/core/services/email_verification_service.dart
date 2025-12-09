import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Send verification email
  Future<void> sendVerificationEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  // Reload user to check verification status
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }
}

