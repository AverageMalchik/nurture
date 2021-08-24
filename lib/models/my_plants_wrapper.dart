import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nurture/common/my_plants_list.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class MyPlantsWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: database.getMyPlants(),
      builder: (context, snapshot) {
        print('inside my_plants FutureBuilder');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            color: Colors.white,
          );
        } else {
          if (!snapshot.hasData || snapshot.data!.data()!.isEmpty) {
            return Text('No plants have been added.');
          } else {
            Map<String, dynamic> map = snapshot.data!.data()!;
            return MyPlantsList(myPlantsMap: map);
          }
        }
      },
    );
  }
}
