
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:todo_list/amplifyconfiguration.dart';

 class TaskListAuthUtils {
   static  final LocalAuthentication _localAuth = LocalAuthentication();
   static bool configured = false;
   static  bool canCheckBiometrics = false;
   TaskListAuthUtils._();


   static void init() async {
     canCheckBiometrics = await _localAuth.canCheckBiometrics;
     await configureAmplify();
     configured = true;
   }
  static Future<void> configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito(
        secureStorageFactory: AmplifySecureStorage.factoryFrom(

        )
      );
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      safePrint("An error occurred configuring Amplify: $e");
    }
  }

  static Future<bool> isUserSignedIn() async {
    final result = await Amplify.Auth.fetchAuthSession();
    return result.isSignedIn;
  }
  static Future<void> signOutCurrentUser() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }
}