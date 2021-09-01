import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/UI/drawer_ui.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final _scaffold = GlobalKey<ScaffoldState>();
  String? _currentName;
  String? _prev;

  bool _guest = false;
  bool _visible = false;
  bool _same = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 1));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          _visible = false;
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          error.add(false);
          break;
        case AnimationStatus.completed:
          _visible = true;
          break;
      }
    });
    error.add(false);
    super.initState();
  }

  @override
  void dispose() {
    error.close();
    _controller.dispose();
    _text.dispose();
    super.dispose();
  }

  var _text = TextEditingController();
  var error = StreamController<bool>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final database = Provider.of<DatabaseService>(context, listen: false);
    if (user.isAnonymous) _guest = true;
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'MazzardBold',
              fontSize: 25,
              letterSpacing: 1,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () => _scaffold.currentState?.openDrawer(),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            CartIcon(),
          ],
        ),
        drawer: DrawerUI(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                StreamBuilder<UserPhotoReference>(
                    stream: database.userPhotoReferenceStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return CircularProgressIndicator(
                          color: Colors.greenAccent,
                        );
                      else {
                        return CircleAvatar(
                          radius: 100,
                          backgroundImage:
                              NetworkImage(snapshot.data!.photoURL),
                          backgroundColor: Colors.transparent,
                        );
                      }
                    }),
                Positioned(
                    top: 3,
                    right: 2,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    )),
                Positioned(
                    top: 3,
                    right: 2,
                    child: IconButton(
                      iconSize: 30,
                      disabledColor: Colors.blueGrey[200],
                      color: Colors.blueGrey[800],
                      onPressed: _guest
                          ? null
                          : () => showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      child: UnsplashDialog(),
                                    )
                                  ],
                                );
                              }),
                      icon: Icon(Icons.camera_alt_rounded),
                    ))
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 4,
                  child: StreamBuilder<UserNameReference>(
                      stream: database.userNameReferenceStream(),
                      builder: (context, snapshot) {
                        print('inside UserNameReference StreamBuilder');

                        if (!snapshot.hasData)
                          return SizedBox();
                        else {
                          _prev = snapshot.data!.displayName;
                          final displayNameReference = snapshot.data;
                          _text.text =
                              _currentName ?? displayNameReference!.displayName;
                          return Container(
                            constraints: BoxConstraints(maxWidth: 200),
                            child: StreamBuilder<bool>(
                                stream: error.stream,
                                builder: (context, snapshot) {
                                  print('inside error StreamBuilder');
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    return SizedBox();
                                  else
                                    return TextFormField(
                                      controller: _text,
                                      autocorrect: false,
                                      enableInteractiveSelection: false,
                                      enableSuggestions: false,
                                      maxLength: 8,
                                      enabled: !_guest,
                                      decoration: textInputDecoration.copyWith(
                                        labelStyle: TextStyle(
                                          color: snapshot.data!
                                              ? Colors.red
                                              : Colors.black,
                                          fontSize: 12,
                                          fontFamily: 'MazzardLight',
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        errorText: snapshot.data! ? '' : null,
                                      ),
                                      onChanged: (val) {
                                        error.add(false);
                                        _controller.reverse();
                                        _currentName = val;
                                      },
                                    );
                                }),
                          );
                        }
                      }),
                ),
                SizedBox(
                  width: 15,
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      onPressed: _guest
                          ? () => null
                          : () async {
                              if (_currentName != null &&
                                  _text.text.isNotEmpty) {
                                _same = _currentName! == _prev;
                                if (!_same) {
                                  error.add(false);
                                  if (_visible) _controller.reverse();
                                  bool result = _currentName != 'Guest'
                                      ? await database
                                          .checkDisplayName(_currentName!)
                                      : false;
                                  if (result) {
                                    await DatabaseService(uid: user.uid)
                                        .addDisplayName(
                                      UserNameReference(_currentName!),
                                    );
                                  } else {
                                    error.add(true);
                                    _controller.forward();
                                  }
                                }
                              }
                            },
                      icon: Icon(Icons.edit),
                      iconSize: 25,
                      color: Colors.blueGrey[800],
                      disabledColor: Colors.blueGrey[200],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            FadeTransition(
                opacity: _animation,
                child: Text(
                  'Display Name already taken',
                  style: TextStyle(color: Colors.red),
                )),
            SizedBox(
              height: 20,
            ),
            // TextButton(
            //   onPressed: _guest
            //       ? () => null
            //       : () async {
            //           if (_visible) _controller.reverse();
            //           bool result =
            //               await database.checkDisplayName(_currentName!);
            //           if (result) {
            //             await DatabaseService(uid: user.uid)
            //                 .addDisplayName(UserNameReference(_currentName!));
            //           } else {
            //             _controller.forward();
            //           }
            //         },
            //   child: Text('Update'),
            // ),
          ],
        ),
      ),
    );
  }
}
