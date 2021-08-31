import 'package:flutter/material.dart';
import 'package:nurture/common/my_plants_list.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class MyPlantsWrapper extends StatefulWidget {
  @override
  _MyPlantsWrapperState createState() => _MyPlantsWrapperState();
}

class _MyPlantsWrapperState extends State<MyPlantsWrapper> {
  @override
  Widget build(BuildContext context) {
    print('inside my_plant_wrapper build');
    final database = Provider.of<DatabaseService>(context, listen: false);
    final plants = Provider.of<List<PlantReference>>(context, listen: true);
    return FutureBuilder<List<MyPlantreference>>(
      future: database.getMyPlants(plants),
      builder: (context, snapshot) {
        print('inside my_plants FutureBuilder');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: Colors.white,
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData || snapshot.data!.length == 0) {
            return Center(
                child: Text(
              'No plants have been added.',
              style: TextStyle(color: Colors.white),
            ));
          } else {
            return MyPlantsList(listMyPlant: snapshot.data!);
          }
        } else {
          return SizedBox();
        }
      },
    );
    // return _loading ? Center(child: CircularProgressIndicator(color: Colors.white,),) :
  }
}
