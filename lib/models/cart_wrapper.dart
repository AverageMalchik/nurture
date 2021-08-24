import 'package:flutter/material.dart';
import 'package:nurture/common/cart_list.dart';
import 'package:nurture/models/plant.dart';
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
