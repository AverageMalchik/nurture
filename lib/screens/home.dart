import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/models/drawer_model.dart';
import 'package:nurture/models/plants_list.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Home',
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
        key: _scaffold,
        drawer: DrawerModel(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              ListPlants(),
            ],
          ),
        ),
      ),
    );
  }
}
