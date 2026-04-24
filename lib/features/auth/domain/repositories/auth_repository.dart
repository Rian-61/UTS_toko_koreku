import '../../data/models/auth_response_model.dart';
 
abstract class AuthRepository {
  Future<AuthResponseModel> verifyFirebaseToken(String firebaseToken);
  Future<void> signOut();
}
