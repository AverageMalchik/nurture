import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nurture/models/cart_model.dart';
import 'package:nurture/models/plant.dart';
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
            //remember providers can be used for both streams and values
            return MultiProvider(
              providers: [
                Provider<User>.value(value: user),
                Provider<DatabaseService>(
                  create: (_) => DatabaseService(uid: user.uid),
                ),
                StreamProvider<List<PlantReference>>.value(
                    value: DatabaseService().plantReferenceStream(),
                    initialData: <PlantReference>[]),
                ChangeNotifierProvider(create: (_) => CartModel()),
              ],
              child: builder(context, snapshot),
            );
          } else {
            return builder(context, snapshot);
          }
        });
  }
}
