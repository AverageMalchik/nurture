import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class CartModel extends ChangeNotifier {
  List<PlantLite> list = [];
  List<PlantLite> get plantLites => list;
  int get length => list.length;

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  void add(PlantReference plant, int count) {
    list.add(PlantLite(plant: plant, count: count));
    notifyListeners();
  }

  void edit(PlantReference plant, int index, int count) {
    print('list.length inside edit function ' + list.length.toString());
    list[index] = PlantLite(plant: plant, count: count);
    notifyListeners();
  }

  void remove(int index) {
    list.removeAt(index);
    notifyListeners();
  }

  void removeAll() {
    list.clear();
    notifyListeners();
  }

  Future<void> resetCache(BuildContext context, int initialCount) async {
    bool _reset = true;
    final user = Provider.of<User>(context, listen: false);
    Map<String, dynamic> map = {};
    for (PlantLite element in list) {
      _reset = element.count != initialCount;
      if (!_reset) break;
      map['${element.plant.id}'] = element.count;
    }
    if (_reset) {
      await usersCollection
          .doc(user.uid)
          .collection('actions')
          .doc('cart')
          .set(map);
    }
  }
}
