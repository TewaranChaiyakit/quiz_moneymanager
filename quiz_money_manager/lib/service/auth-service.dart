import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Registration method with password confirmation check
  Future<String?> registration({
    required String email,
    required String password,
    required String confirm,
  }) async {
    print('AuthService - Email: $email');
    print('AuthService - Password: $password');
    print('AuthService - Confirm: $confirm');

    if (password != confirm) {
      return "รหัสผ่านไม่ตรงกัน";
    }
    if (password.length < 8) {
      return "รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร";
    }

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseError(e);
    } catch (e) {
      return "เกิดข้อผิดพลาด: $e";
    }
  }

  // Signin method
  Future<String?> signin({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseError(e);
    } catch (e) {
      return "เกิดข้อผิดพลาด: $e";
    }
  }

  // Helper function to handle Firebase errors and translate to friendly messages
  String _handleFirebaseError(FirebaseAuthException e) {
    print('Firebase error: ${e.code}'); // เพิ่มบรรทัดนี้
    switch (e.code) {
      case 'invalid-email':
        return "รูปแบบอีเมลไม่ถูกต้อง";
      case 'user-not-found':
        return "ไม่พบผู้ใช้ที่ตรงกับข้อมูลที่ให้มา";
      case 'wrong-password':
        return "รหัสผ่านไม่ถูกต้อง";
      case 'email-already-in-use':
        return "อีเมลนี้ถูกใช้งานแล้ว";
      default:
        return "เกิดข้อผิดพลาด: ${e.message}";
    }
  }
}
