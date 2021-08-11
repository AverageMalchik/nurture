import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurture/models/drawer_model.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _groupValue = 0;

  final _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        drawer: DrawerModel(),
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () => _scaffold.currentState!.openDrawer(),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.black,
                ))
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Display Welcome Screen after signing in?',
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                CupertinoSegmentedControl(
                    unselectedColor: Colors.white,
                    selectedColor: Colors.blue[800],
                    borderColor: Colors.blue[800],
                    children: <int, Widget>{
                      0: Padding(
                          padding: EdgeInsets.all(8.0), child: Text('Yes')),
                      1: Padding(padding: EdgeInsets.all(8), child: Text('No'))
                    },
                    groupValue: _groupValue,
                    onValueChanged: (value) {
                      setState(() {
                        _groupValue = value as int;
                      });
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
