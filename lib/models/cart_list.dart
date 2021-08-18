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

  ListCart({required this.plants});
  @override
  _ListCartState createState() => _ListCartState();
}

class _ListCartState extends State<ListCart>
    with SingleTickerProviderStateMixin {
  final _state = GlobalKey<AnimatedListState>();

  CurveTween _curve = CurveTween(curve: Curves.elasticOut);
  Tween<Offset> _offsetL =
      Tween<Offset>(begin: Offset(-2, 0), end: Offset.zero);
  Tween<Offset> _offsetR = Tween<Offset>(begin: Offset(2, 0), end: Offset.zero);

  late Map<String, dynamic> map;
  late List<dynamic> listValues;
  late List<String> listKeys;
  List<CartTile> listCartTile = [];

  late AnimationController _opacityController;
  late Animation<double> _opacity;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      addtoList();
    });
    _opacityController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _opacityController, curve: Curves.easeIn));
    super.initState();
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  void addtoList() {
    // Future f = Future(() {}); //use for staggered effect
    Timer(Duration(milliseconds: 200), () {
      listKeys.forEach((plant) {
        for (int i = 0; i < widget.plants.length; i++) {
          if (widget.plants[i].id == plant) {
            listCartTile.add(CartTile(
                key: ValueKey(widget.plants[i].cover),
                onRemove: _removeTile,
                plant: widget.plants[i],
                count: listValues.elementAt(listKeys.indexOf(plant))));
            _state.currentState!.insertItem(listCartTile.length - 1);
            break;
          }
        }
      });
    });
  }

  void _removeTile(String id) {
    for (int i = 0; i < listCartTile.length; i++) {
      if (listCartTile[i].plant.id == id) {
        CartTile temp = listCartTile[i];
        listCartTile.removeAt(i);

        _state.currentState!.removeItem(i, (context, animation) {
          return CartTile(
            key: ValueKey(temp.plant.cover),
            animation: animation,
            onRemove: _removeTile,
            plant: temp.plant,
            count: temp.count,
          );
        }, duration: Duration(milliseconds: 1000));

        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: database.getCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data!.exists && snapshot.hasData) {
            map = snapshot.data!.data()!;
            listValues = map.values.toList();
            listKeys = map.keys.toList();
          } else {
            map = {};
          }
          if (map.length == 0) {
            _opacityController.forward();
            return FadeTransition(
              opacity: _opacity,
              child: Center(
                child: Text('Cart is empty.'),
              ),
            );
          } else {
            return AnimatedList(
              key: _state,
              itemBuilder: (context, index, animation) {
                return SlideTransition(
                  position: animation
                      .drive(_curve)
                      .drive(index.isOdd ? _offsetR : _offsetL),
                  child: listCartTile[index],
                );
              },
            );
          }
        }
      },
    );
  }
}
