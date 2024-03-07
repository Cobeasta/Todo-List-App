import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:todo_list/amplifyconfiguration.dart';

import 'user_repository.dart';

@singleton
class TaskListAuth {
  final UserRepository _userRepository;
  late StreamSubscription<AuthHubEvent> subscription;

  int localUserId = -1;
  bool signedIn = false;

  String _amplifyUserId = "";
  String _username = "";

  TaskListAuth(this._userRepository) {
    subscription = Amplify.Hub.listen(HubChannel.Auth, (AuthHubEvent event) {
      switch (event.type) {
        case AuthHubEventType.signedIn:
          _handleSignin(event.payload);
          safePrint('User is signed in.');
          break;
        case AuthHubEventType.signedOut:
          safePrint('User is signed out.');
          _handleSignOut(event.payload);
          break;
        case AuthHubEventType.sessionExpired:
          safePrint('The session has expired.');
          break;
        case AuthHubEventType.userDeleted:
          safePrint('The user has been deleted.');
          break;
      }
    });
  }
  Future<void> _fetchUserDetails () async {
    try {
      var user = await Amplify.Auth.getCurrentUser();
      _handleSignin(user);
    }on AuthException catch(e) {
      safePrint("Could not fetch user details");
    }

}

void init() async {
    await _configureAmplify();
    await _fetchUserDetails();
}
  Future<void> _configureAmplify() async {
    if (Amplify.isConfigured) {
      return;
    }
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      safePrint("An error occurred configuring Amplify: $e");
    }
  }

  static Future<void> signOutCurrentUser() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }

  Future<void> _handleSignin(AuthUser? user) async {
    if (user == null) {
      safePrint("Problem signing in user");
    } else {
      _amplifyUserId = user.userId;
      _username = user.username;

      var localUser = await _userRepository.getUserByUserId(_amplifyUserId);
      if (localUser == null) {
        _userRepository.adduser(_amplifyUserId, _username);
      } else {
        localUserId = localUser.id!;
      }
    }
  }

  void _handleSignOut(AuthUser? payload) {
    SystemNavigator.pop();
  }
}
