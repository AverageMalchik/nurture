import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurture/screens/cart.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

Widget loadingShimmer() {
  return Shimmer.fromColors(
      child: Container(
        margin: EdgeInsets.all(10),
        height: 300,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.black),
      ),
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200);
}

class CartIcon extends StatefulWidget {
  @override
  _CartIconState createState() => _CartIconState();
}

class _CartIconState extends State<CartIcon> {
  double _opacity = 0.0;
  int _items = 0;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    print('inside cart icon build');
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: database.getCount(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _items = 0;
            var _list = snapshot.data!.data()!.values.toList();
            for (int items in _list) {
              _items += items;
            }
            _opacity = _items != 0 ? 1.0 : 0.0;
          } else {
            _opacity = 0;
            _items = 0;
          }
          return Stack(
            children: [
              IconButton(
                  iconSize: 30,
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Cart())),
                  icon: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.black,
                  )),
              Positioned(
                  top: 5,
                  left: 1,
                  child: AnimatedOpacity(
                    curve: Curves.easeInCubic,
                    duration: Duration(milliseconds: 500),
                    opacity: _opacity,
                    child: Container(
                      alignment: Alignment.center,
                      width: 20,
                      height: 20,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueGrey,
                      ),
                      child: Text(
                        '${_items.toString()}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ))
            ],
          );
        });
  }
}
