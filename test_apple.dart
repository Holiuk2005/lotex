import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() async {
  try {
     final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print('SUCCESS');
  } catch (e) {
      print('ERROR: $e');
  }
}
