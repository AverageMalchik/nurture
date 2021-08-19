import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/models/cart_list.dart';
import 'package:nurture/models/cart_model.dart';
import 'package:nurture/models/cart_wrapper.dart';
import 'package:nurture/models/drawer_model.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/plant_tile.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  final int initialCount;
  Cart({required this.initialCount});
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Map<String, dynamic> map = {};

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void loadingOverlay(BuildContext context) {
    context.loaderOverlay.show();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xffebeaef),
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () async {
            loadingOverlay(context);
            await cart.resetCache(context, widget.initialCount);
            cart.removeAll();
            context.loaderOverlay.hide();
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 5,
            ),
            Container(
                constraints: BoxConstraints(
                  maxHeight: 700,
                  maxWidth: 400,
                ),
                child: CartWrapper()),
            SizedBox(
              height: 5,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                color: Colors.white,
                thickness: 1,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Bag Total'),
                        SizedBox(
                          width: 10,
                        ),
                        Consumer<CartModel>(
                          builder: (context, model, child) {
                            print('consumer-builder-1');
                            int items = 0;
                            for (var plantL in model.plantLites)
                              items += plantL.count;
                            return Text('($items items)');
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Consumer<CartModel>(builder: (context, model, child) {
                          print('consumer-builder-2');
                          int sum = 0;
                          for (var plantL in model.plantLites)
                            sum += plantL.plant.pricing * plantL.count;
                          return Text('\$' + sum.toString(),
                              style: TextStyle(
                                fontSize: 20,
                              ));
                        })
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
