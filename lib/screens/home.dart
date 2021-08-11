import 'package:flutter/material.dart';
import 'package:nurture/models/drawer_model.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/plants_list.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:nurture/models/plant_tile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return StreamProvider<List<PlantReference>>.value(
      value: database.plantReferenceStream(),
      initialData: <PlantReference>[],
      child: SafeArea(
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
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black,
                  ))
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
      ),
    );
  }
}
