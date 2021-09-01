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
              backgroundColor: Color(0xffecfddb),
              body: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NURTURE',
                            style: TextStyle(
                                fontSize: 40, fontFamily: 'MazzardBold'),
                          ),
                          SizedBox(
                            height: 100,
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
                                child: Text('Sign in as Guest',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'MazzardBold',
                                      fontWeight: FontWeight.w900,
                                    )),
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
              backgroundColor: Color(0xffecfddb),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'NURTURE',
                      style: TextStyle(
                        fontSize: 40,
                        fontFamily: 'MazzardBold',
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _loading = true;
                        });
                        await _auth.signInGoogle();
                      },
                      child: GoogleButton(),
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
                                      'Some critical features might be disabled',
                                      style:
                                          TextStyle(fontFamily: 'InterMedium'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                          'Cancel',
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'InterMedium'),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          setState(() {
                                            _loading = true;
                                          });
                                          Navigator.pop(context, 'OK');
                                          await _auth.signInAnonymously();
                                        },
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'InterMedium'),
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: Text(
                            'Sign in as Guest',
                            style: TextStyle(
                              fontFamily: 'MazzardLight',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
