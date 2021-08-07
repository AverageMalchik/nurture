import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nurture/models/drawer_model.dart';
import 'package:nurture/models/unsplash_dialog.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var _scaffold = GlobalKey<ScaffoldState>();
  String? _currentName;

  bool _guest = false;
  double _opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final database = Provider.of<DatabaseService>(context, listen: false);
    if (user.displayName == 'Guest') _guest = true;
    return Scaffold(
      key: _scaffold,
      drawer: DrawerModel(),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Profile'),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.greenAccent,
                      ),
                      StreamBuilder<UserPhotoReference>(
                          stream: database.userPhotoReferenceStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return SizedBox();
                            else {
                              final photoReference = snapshot.data;
                              return CircleAvatar(
                                radius: 100,
                                backgroundImage: NetworkImage(photoReference!
                                        .photoURL ??
                                    'https://media.tarkett-image.com/large/TH_24567080_24594080_24596080_24601080_24563080_24565080_24588080_001.jpg'),
                                backgroundColor: Colors.transparent,
                              );
                            }
                          }),
                    ],
                  ),
                  IconButton(
                    onPressed: _guest
                        ? () => null
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
                  )
                ],
              ),
              SizedBox(
                height: 10,
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
                        onChanged: (val) => setState(() {
                          _currentName = val;
                        }),
                      );
                    }
                  }),
              SizedBox(
                height: 20,
              ),
              AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: _opacity,
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
                          setState(() {
                            _opacity = 0.0;
                          });
                          bool result =
                              await database.checkDisplayName(_currentName!);
                          if (result) {
                            await DatabaseService(uid: user.uid).addDisplayName(
                                UserNameReference(_currentName!));
                          } else {
                            setState(() {
                              _opacity = 1.0;
                            });
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
          Positioned(
              left: 10,
              top: 20,
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffold.currentState?.openDrawer(),
              ))
        ],
      ),
    );
  }
}
