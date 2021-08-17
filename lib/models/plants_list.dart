import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/plant_tile.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class ListPlants extends StatefulWidget {
  @override
  _ListPlantsState createState() => _ListPlantsState();
}

class _ListPlantsState extends State<ListPlants> {
  @override
  Widget build(BuildContext context) {
    final plants = Provider.of<List<PlantReference>>(context, listen: true);
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        return PlantTile(
          plant: plants[index],
        );
      },
      shrinkWrap: true,
    );
  }
}
