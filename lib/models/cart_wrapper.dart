import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nurture/models/cart_list.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class CartWrapper extends StatefulWidget {
  @override
  _CartWrapperState createState() => _CartWrapperState();
}

class _CartWrapperState extends State<CartWrapper> {
  @override
  Widget build(BuildContext context) {
    final plants = Provider.of<List<PlantReference>>(context, listen: true);
    return ListCart(plants: plants);
  }
}
