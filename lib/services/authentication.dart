import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //sign in anonymously
  Future<void> signInasGuest() async {
    try {
      await _auth
          .signInWithEmailAndPassword(
              email: 'guest@baboochka.com', password: 'guest123')
          .then((value) => value.user!.updateDisplayName('Guest'));
    } on FirebaseAuthException catch (err) {
      print(err.toString());
    }
  }

  //sign in with gmail id
  Future<void> signInGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (err) {
      print(err.toString());
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (err) {
      print(err.toString());
    }
  }

  //get stream of user
  Stream<User?> get userStream {
    return _auth.authStateChanges();
  }
}
