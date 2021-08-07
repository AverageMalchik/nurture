import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:nurture/services/authentication.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthenticationService _auth = AuthenticationService();
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return _loading
        ? SafeArea(
            child: Scaffold(
              body: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('NURTURE'),
                          SizedBox(
                            height: 20,
                          ),
                          SignInButton(
                            Buttons.Google,
                            onPressed: () {},
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.orange),
                                onPressed: () {},
                                child: Text('Sign in as Guest'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      strokeWidth: 4,
                      color: Colors.red[900],
                    )
                  ],
                ),
              ),
            ),
          )
        : SafeArea(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('NURTURE'),
                    SizedBox(
                      height: 20,
                    ),
                    SignInButton(
                      Buttons.Google,
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        await _auth.signInGoogle();
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.orange),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Icon(Icons.warning_amber_rounded),
                                    content: Text(
                                        'Some critical features might be disabled'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: Text('Cancel')),
                                      TextButton(
                                          onPressed: () async {
                                            setState(() {
                                              _loading = true;
                                            });
                                            Navigator.pop(context, 'OK');
                                            await _auth.signInasGuest();
                                          },
                                          child: Text('OK'))
                                    ],
                                  );
                                });
                          },
                          child: Text('Sign in as Guest'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
