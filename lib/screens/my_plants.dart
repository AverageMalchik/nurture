import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nurture/UI/drawer_ui.dart';
import 'package:nurture/models/my_plants_wrapper.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class MyInheritedList extends InheritedWidget {
  final List<MyPlantreference> list;
  final Function addList;
  final Function editList;
  final Function clearList;
  final Function publishList;
  const MyInheritedList({
    Key? key,
    required this.list,
    required Widget child,
    required this.addList,
    required this.editList,
    required this.clearList,
    required this.publishList,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static MyInheritedList of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyInheritedList>()!;
}

class RootWidget extends StatefulWidget {
  @override
  _RootWidgetState createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  List<MyPlantreference> list = [];
  List<MyPlantreference> get myPlantReferences => list;

  void addList(MyPlantreference myPlant) {
    list.add(myPlant);
  }

  void editList(int index, MyPlantreference myPlant) {
    list[index] = myPlant;
  }

  void clearList() {
    list.clear();
  }

  Future<void> publishList(BuildContext context) async {
    final database = Provider.of<DatabaseService>(context, listen: false);
    list.forEach((myPlantReference) async {
      await database.changeMyPlants(
          myPlantReference.plant.id,
          myPlantReference.purchase,
          UserMyPlants(
              count: myPlantReference.count,
              last: myPlantReference.last,
              water: myPlantReference.time));
    });
    clearList();
  }

  @override
  Widget build(BuildContext context) {
    return MyInheritedList(
      list: list,
      child: MyPlants(),
      addList: addList,
      editList: editList,
      clearList: clearList,
      publishList: publishList,
    );
  }
}

class MyPlants extends StatefulWidget {
  @override
  _MyPlantsState createState() => _MyPlantsState();
}

class _MyPlantsState extends State<MyPlants> {
  final _scaffold = GlobalKey<ScaffoldState>();

  void close() {
    _scaffold.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final inherited = MyInheritedList.of(context);
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        drawer: DrawerUI(),
        backgroundColor: Color(0xff000a12),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'My Plants.',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'MazzardBold',
              fontSize: 30,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () async {
              await inherited.publishList(context);
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

  void loadingOverlay(BuildContext context) {
    context.loaderOverlay.show();
  }
}
