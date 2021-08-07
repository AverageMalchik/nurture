import 'package:flutter/material.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/screens/home.dart';
import 'package:nurture/screens/profile.dart';
import 'package:nurture/services/authentication.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class DrawerModel extends StatefulWidget {
  @override
  _DrawerModelState createState() => _DrawerModelState();
}

class _DrawerModelState extends State<DrawerModel> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(color: Colors.cyan),
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
          TextButton(onPressed: () {}, child: Text('My Plants')),
          TextButton(
              onPressed: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => Home())),
              child: Text('Home')),
          TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Profile())),
              child: Text('Profile')),
          TextButton(onPressed: () {}, child: Text('Favourites')),
          TextButton(onPressed: () {}, child: Text('Settings')),
          TextButton(
              onPressed: () async {
                await AuthenticationService().signOut();
              },
              child: Text('Sign Out')),
          SizedBox(
            height: 20,
          ),
          IconButton(
              onPressed: () => Navigator.pop(context), icon: Icon(Icons.close))
        ],
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
              radius: 40,
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
            return Text(displayNameReference!.displayName);
          }
        });
  }
}
