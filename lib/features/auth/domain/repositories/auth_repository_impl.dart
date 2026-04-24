import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/services/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/models/auth_response_model.dart';
import 'auth_repository.dart';
 
class AuthRepositoryImpl implements AuthRepository {
  final _dio = DioClient.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
 
  @override
  Future<AuthResponseModel> verifyFirebaseToken(String firebaseToken) async {
    final response = await _dio.post(
      ApiConstants.verifyToken,
      data: {'firebase_token': firebaseToken},
    );
    final authData = AuthResponseModel.fromJson(response.data['data']);
    await SecureStorage.saveToken(authData.accessToken);
    return authData;
  }
 
  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await SecureStorage.deleteToken();
  }
}
