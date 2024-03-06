
import 'package:amplify_flutter/amplify_flutter.dart';

class Auth {

  Future<bool> isUserSignedIn() async {
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }
}