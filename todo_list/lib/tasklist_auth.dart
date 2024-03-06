
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
     _fetchCurrentUserAttributes();
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
    final session = await _fetchCognitoAuthSession();
    return session?.isSignedIn ?? false;
  }
  static Future<void> signOutCurrentUser() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }
   static Future<CognitoAuthSession?> _fetchCognitoAuthSession() async {
     try {
       final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
       var result =   await cognitoPlugin.fetchAuthSession();
       return result;
     } on AuthException catch (e) {
       safePrint('Error retrieving auth session: ${e.message}');
       return null;
     }
   }
   static Future<void> _fetchCurrentUserAttributes() async {
     try {
       final result = await Amplify.Auth.fetchUserAttributes();
       for (final element in result) {
         safePrint('key: ${element.userAttributeKey}; value: ${element.value}');
       }
     } on AuthException catch (e) {
       safePrint('Error fetching user attributes: ${e.message}');
     }
   }
}