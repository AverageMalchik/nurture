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
  var _scaffold = GlobalKey<ScaffoldState>();
  String? _currentName;

  bool _guest = false;
  bool _visible = false;

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
          break;
        case AnimationStatus.completed:
          _visible = true;
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final database = Provider.of<DatabaseService>(context, listen: false);
    if (user.displayName == 'Guest') _guest = true;
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.black),
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
                        final photoReference = snapshot.data;
                        return CircleAvatar(
                          radius: 100,
                          backgroundImage: NetworkImage(photoReference
                                  ?.photoURL ??
                              'https://media.tarkett-image.com/large/TH_24567080_24594080_24596080_24601080_24563080_24565080_24588080_001.jpg'),
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
            StreamBuilder<UserNameReference>(
                stream: database.userNameReferenceStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return SizedBox();
                  else {
                    final displayNameReference = snapshot.data;
                    return TextFormField(
                      enabled: !_guest,
                      initialValue:
                          _currentName ?? displayNameReference!.displayName,
                      onChanged: (val) => _currentName = val,
                    );
                  }
                }),
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
            TextButton(
                onPressed: _guest
                    ? () => null
                    : () async {
                        if (_visible) _controller.reverse();
                        bool result =
                            await database.checkDisplayName(_currentName!);
                        if (result) {
                          await DatabaseService(uid: user.uid)
                              .addDisplayName(UserNameReference(_currentName!));
                        } else {
                          _controller.forward();
                        }
                      },
                child: Text('Update')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'))
          ],
        ),
      ),
    );
  }
}
