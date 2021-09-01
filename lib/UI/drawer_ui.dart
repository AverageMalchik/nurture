import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/screens/favorites.dart';
import 'package:nurture/screens/home.dart';
import 'package:nurture/screens/my_plants.dart';
import 'package:nurture/screens/profile.dart';
import 'package:nurture/services/authentication.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class DrawerUI extends StatefulWidget {
  @override
  _DrawerUIState createState() => _DrawerUIState();
}

class _DrawerUIState extends State<DrawerUI> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: Color(0xff333333),
          borderRadius: BorderRadius.horizontal(
            left: Radius.zero,
            right: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              margin: EdgeInsets.fromLTRB(0, 20, 20, 20),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Color(0xff292929),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                  ),
                  _showAvatar(context),
                  SizedBox(
                    width: 25,
                  ),
                  _showDisplayName(context)
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                MenuIcon(baseColor: Colors.green),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RootWidget())),
                  child: Text(
                    'My Plants',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'MazzardBold',
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                MenuIcon(baseColor: Colors.orange),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Home())),
                  child: Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.orange,
                      fontFamily: 'MazzardBold',
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                MenuIcon(baseColor: Colors.red),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Favorites())),
                  child: Text(
                    'Favorites',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'MazzardBold',
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                MenuIcon(baseColor: Colors.blue),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/profile');
                  },
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'MazzardBold',
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                MenuIcon(baseColor: Colors.black),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: !user.isAnonymous
                      ? () async {
                          await AuthenticationService().signOut();
                        }
                      : () async {
                          user.delete();
                        },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'MazzardBold',
                      fontSize: 20,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          offset: Offset(-2, 2),
                          blurRadius: 1,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _showAvatar(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return StreamBuilder<UserPhotoReference>(
        stream: database.userPhotoReferenceStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return SizedBox();
          else {
            final photoReference = snapshot.data;
            return CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(photoReference!.photoURL),
              backgroundColor: Colors.transparent,
            );
          }
        });
  }

  Widget _showDisplayName(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return StreamBuilder<UserNameReference>(
        stream: database.userNameReferenceStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return SizedBox();
          else {
            final displayNameReference = snapshot.data;
            return Wrap(
              children: [
                Text(
                  displayNameReference!.displayName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'MazzardBold',
                      letterSpacing: 1),
                ),
              ],
            );
          }
        });
  }
}
