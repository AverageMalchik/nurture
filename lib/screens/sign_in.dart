import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
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
                          GoogleButton(),
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
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _loading = true;
                        });
                        await _auth.signInGoogle();
                      },
                      child: Container(
                        height: 50,
                        width: 180,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 3),
                                  blurRadius: 2,
                                  color: Colors.grey.shade400)
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google_icon.png',
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[700]),
                            )
                          ],
                        ),
                      ),
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
                                            await _auth.signInAnonymously();
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
