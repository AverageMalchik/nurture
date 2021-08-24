import 'package:flutter/material.dart';
import 'package:nurture/UI/drawer_ui.dart';
import 'package:nurture/common/my_plants_list.dart';
import 'package:nurture/models/my_plants_wrapper.dart';

class MyPlants extends StatefulWidget {
  @override
  _MyPlantsState createState() => _MyPlantsState();
}

class _MyPlantsState extends State<MyPlants> {
  var _scaffold = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        drawer: DrawerUI(),
        backgroundColor: Color(0xff000a12),
        appBar: AppBar(
          title: Text(
            'My Plants',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(child: MyPlantsWrapper()),
      ),
    );
  }
}
