import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nurture/screens/home.dart';
import 'package:nurture/screens/sign_in.dart';

class Wrapper extends StatelessWidget {
  final AsyncSnapshot<User?> userSnapshot;
  Wrapper({required this.userSnapshot});
  @override
  Widget build(BuildContext context) {
    if (userSnapshot.connectionState == ConnectionState.active) {
      return userSnapshot.hasData ? Home() : SignIn();
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
