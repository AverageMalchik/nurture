import 'package:flutter/material.dart';
import 'package:nurture/services/authentication.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WrapperBuilder extends StatelessWidget {
  final Widget Function(BuildContext, AsyncSnapshot<User?>) builder;
  WrapperBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<AuthenticationService>(context, listen: false);
    return StreamBuilder<User?>(
        stream: authService.userStream,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user != null) {
            return MultiProvider(
              providers: [
                Provider<User>.value(value: user),
                Provider<DatabaseService>(
                  create: (_) => DatabaseService(uid: user.uid),
                ),
              ],
              child: builder(context, snapshot),
            );
          } else {
            return builder(context, snapshot);
          }
        });
  }
}
