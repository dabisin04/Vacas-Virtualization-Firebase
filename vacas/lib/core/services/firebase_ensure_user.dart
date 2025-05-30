import 'package:firebase_auth/firebase_auth.dart';

Future<void> ensureFirebaseUser() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }
}
