import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/screens/cart.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'cart_tile.dart';

class ListCart extends StatefulWidget {
  final List<PlantReference> plants;
  final Map<String, dynamic> cartMap;
  ListCart({required this.plants, required this.cartMap});
  @override
  _ListCartState createState() => _ListCartState();
}

class _ListCartState extends State<ListCart>
    with SingleTickerProviderStateMixin {
  int sum = 0;
  final _state = GlobalKey<AnimatedListState>();

  CurveTween _curve = CurveTween(curve: Curves.elasticOut);
  Tween<Offset> _offsetL =
      Tween<Offset>(begin: Offset(-2, 0), end: Offset.zero);
  Tween<Offset> _offsetR = Tween<Offset>(begin: Offset(2, 0), end: Offset.zero);

  late Map<String, dynamic> map;
  late List<dynamic> listValues;
  late List<String> listKeys;
  List<CartTile> listCartTile = [];

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      addtoList();
    });
    map = widget.cartMap;
    listValues = map.values.toList();
    for (int value in listValues) {
      sum += value;
    }
    listKeys = map.keys.toList();

    super.initState();
  }

  void addtoList() {
    // Future f = Future(() {}); //use for stagger effect
    Timer(Duration(milliseconds: 200), () {
      listKeys.forEach((plant) {
        for (int i = 0; i < widget.plants.length; i++) {
          if (widget.plants[i].id == plant) {
            listCartTile.add(CartTile(
                plant: widget.plants[i],
                count: listValues.elementAt(listKeys.indexOf(plant))));
            _state.currentState!.insertItem(listCartTile.length - 1);
            break;
          }
        }
      });
    });
  }

  // void _removeTile(String id) {
  //   for (int i = 0; i < listCartTile.length; i++) {
  //     if (listCartTile[i].plant.id == id) {
  //       CartTile temp = listCartTile[i];
  //       listCartTile.removeAt(i);
  //       _state.currentState!.removeItem(i, (context, animation) {
  //         return CartTile(
  //           plant: temp.plant,
  //           count: temp.count,
  //         );
  //       }, duration: Duration(milliseconds: 200));
  //       break;
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty || listKeys.length == 0 || sum == 0) {
      return Center(
        child: Text('Cart is empty.'),
      );
    } else {
      return Container(
        height: listKeys.length * 115,
        constraints: BoxConstraints(
          maxHeight: 4 * 115,
        ),
        child: AnimatedList(
          physics: BouncingScrollPhysics(),
          key: _state,
          itemBuilder: (context, index, animation) {
            print('index: $index');
            print(listCartTile[index].plant.id);
            return SlideTransition(
                position: animation
                    .drive(_curve)
                    .drive(index.isOdd ? _offsetR : _offsetL),
                child: listCartTile[index]);
          },
        ),
      );
    }
  }
}
