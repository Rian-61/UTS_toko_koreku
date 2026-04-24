import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/auth_response_model.dart';
import '../../domain/repositories/auth_repository_impl.dart';
import '../../../../core/services/secure_storage.dart';
 
enum AuthStatus { initial, loading, authenticated, unauthenticated, emailNotVerified, error }
 
class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepositoryImpl();
  final _firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
 
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  UserModel? _user;
 
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
 
  // CEK TOKEN TERSIMPAN
  Future<bool> checkSavedToken() async {
    return await SecureStorage.hasToken();
  }
 
  // REGISTER dengan Email & Password
  Future<void> registerWithEmail(String email, String password, String name) async {
    _setStatus(AuthStatus.loading);
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      await cred.user?.updateDisplayName(name);
      await cred.user?.sendEmailVerification();
      _setStatus(AuthStatus.emailNotVerified);
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Terjadi kesalahan. Coba lagi.');
    }
  }
 
  // LOGIN dengan Email & Password
  Future<void> loginWithEmail(String email, String password) async {
    _setStatus(AuthStatus.loading);
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      await _processFirebaseUser(cred.user);
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Terjadi kesalahan. Coba lagi.');
    }
  }
 
  // LOGIN dengan Google
  Future<void> loginWithGoogle() async {
    _setStatus(AuthStatus.loading);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { _setStatus(AuthStatus.unauthenticated); return; }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _firebaseAuth.signInWithCredential(credential);
      await _processFirebaseUser(cred.user);
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Terjadi kesalahan. Coba lagi.');
    }
  }
 
  // FORGOT PASSWORD
  Future<void> forgotPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
 
  // SIGN OUT
  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    _setStatus(AuthStatus.unauthenticated);
  }
 
  // PROSES FIREBASE USER → kirim token ke backend
  Future<void> _processFirebaseUser(User? user) async {
    if (user == null) { _setStatus(AuthStatus.unauthenticated); return; }
    await user.reload();
    if (!user.emailVerified) { _setStatus(AuthStatus.emailNotVerified); return; }
    final token = await user.getIdToken(true);
    final authData = await _repo.verifyFirebaseToken(token!);
    _user = authData.user;
    _setStatus(AuthStatus.authenticated);
  }
 
  void _setStatus(AuthStatus status) {
    _status = status;
    _errorMessage = null;
    notifyListeners();
  }
 
  void _setError(String msg) {
    _status = AuthStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }
 
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found': return 'Email tidak ditemukan.';
      case 'wrong-password': return 'Password salah.';
      case 'email-already-in-use': return 'Email sudah digunakan.';
      case 'weak-password': return 'Password terlalu lemah (min 6 karakter).';
      case 'invalid-email': return 'Format email tidak valid.';
      case 'too-many-requests': return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default: return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
