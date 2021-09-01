import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nurture/screens/home.dart';
import 'package:nurture/screens/my_plants.dart';
import 'package:nurture/screens/profile.dart';
import 'package:nurture/services/authentication.dart';
import 'package:nurture/wrapper.dart';
import 'package:nurture/wrapper_builder.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<AuthenticationService>(
        create: (_) => AuthenticationService(),
        child: WrapperBuilder(builder: (context, snapshot) {
          return MaterialApp(
            routes: {
              '/myplants': (_) => RootWidget(),
              '/profile': (_) => Profile(),
            },
            theme: ThemeData(
                accentColorBrightness: Brightness.values[0],
                canvasColor: Colors.transparent),
            home: Wrapper(
              userSnapshot: snapshot,
            ),
          );
        }));
  }
}
