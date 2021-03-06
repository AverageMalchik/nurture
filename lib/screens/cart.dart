import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/models/cart_model.dart';
import 'package:nurture/models/cart_wrapper.dart';
import 'package:nurture/screens/home.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  final int initialCount;
  Cart({required this.initialCount});
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _placeOrder;
  late Animation<Offset> _offset;
  late Animation<Color?> _color;

  Map<String, dynamic> map = {};

  double _opacity = 0.0;

  bool _guest = false;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 500));
    _placeOrder = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 5000),
        reverseDuration: Duration(milliseconds: 800));
    _offset = Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _placeOrder,
            curve: Curves.ease,
            reverseCurve: Curves.easeOutBack));

    _color = ColorTween(begin: Colors.grey, end: Colors.white).animate(
        CurvedAnimation(
            parent: _placeOrder,
            curve: Interval(0.1, 0.5),
            reverseCurve: Interval(0.1, 0.5)));
    _placeOrder.addStatusListener((status) async {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          _opacity = 1.0;
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _placeOrder.dispose();
    _controller.dispose();
    super.dispose();
  }

  void loadingOverlay(BuildContext context) {
    context.loaderOverlay.show();
  }

  Future<void> _next(BuildContext context) async {
    final database = Provider.of<DatabaseService>(context, listen: false);
    final cart = Provider.of<CartModel>(context, listen: false);
    await database.placeOrder(cart.plantLites);
    cart.removeAll();
    showGeneralDialog(
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container(
            height: 200,
            width: 300,
            child: SimpleDialog(
              title: Text(
                'Congratulations',
                style: TextStyle(
                  fontSize: 25,
                  letterSpacing: 1,
                  fontFamily: 'MazzardBold',
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              titlePadding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      'Your order has been placed.',
                      style: TextStyle(
                        fontFamily: 'InterMedium',
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => Home())),
                      child: Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontFamily: 'InterMedium',
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(primary: Colors.amber[800]),
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                )
              ],
            ),
          );
        });
    await database.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    final cart = Provider.of<CartModel>(context, listen: false);
    final user = Provider.of<User>(context, listen: false);
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xffebeaef),
      appBar: AppBar(
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => Home(),
              ),
            );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Cart.',
            style: TextStyle(
              color: Colors.pink,
              fontFamily: 'MazzardExtraBold',
              fontSize: 40,
              letterSpacing: 2,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Flexible(
            child: Container(
                constraints: BoxConstraints(
                  maxHeight: 750,
                  maxWidth: 400,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CartWrapper(),
                )),
          ),
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
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Bag Total',
                        style: TextStyle(
                          fontFamily: 'MazzardLight',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Consumer<CartModel>(
                        builder: (context, model, child) {
                          int items = 0;
                          for (var plantL in model.plantLites)
                            items += plantL.count;
                          return Text(
                            '($items items)',
                            style: TextStyle(
                              fontFamily: 'MazzardLight',
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Consumer<CartModel>(
                        builder: (context, model, child) {
                          int sum = 0;
                          for (var plantL in model.plantLites)
                            sum += plantL.plant.pricing * plantL.count;
                          return Text(
                            '\$' + sum.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'MazzardBold',
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, -2),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  //Put Consumer here
                  Consumer<CartModel>(
                    child: SizedBox(),
                    builder: (context, model, child) {
                      int items = 0;
                      for (var plantL in model.plantLites)
                        items += plantL.count;
                      if (items == 0)
                        return SizedBox();
                      else
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 40,
                              width: 432,
                            ),
                            AnimatedBuilder(
                              animation: _placeOrder.view,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _offset,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: 0,
                              child: ClipPath(
                                clipper: SWFOClipper(),
                                child: Container(
                                  height: 41,
                                  width: 136,
                                  color: Color(0xffebeaef),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPress: !_guest
                                  ? () {
                                      _placeOrder.forward();
                                    }
                                  : () {},
                              onLongPressUp: !_guest
                                  ? () async {
                                      if (!_placeOrder.isCompleted)
                                        _placeOrder.reverse();
                                      else {
                                        await cart.resetCache(
                                            context, widget.initialCount);
                                        await _next(context);
                                      }
                                    }
                                  : () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Icon(
                                                  Icons.warning_amber_rounded),
                                              content: Text(
                                                'Please sign in to place your order',
                                                style: TextStyle(
                                                  fontFamily: 'InterMedium',
                                                ),
                                              ),
                                              actions: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        loadingOverlay(context);
                                                        cart.removeAll();
                                                        await DatabaseService(
                                                                uid: user.uid)
                                                            .transferData(
                                                                context);
                                                      },
                                                      child: GoogleButton(),
                                                    )
                                                  ],
                                                )
                                              ],
                                            );
                                          });
                                    },
                              child: AnimatedBuilder(
                                animation: _placeOrder.view,
                                builder: (context, child) {
                                  return Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.grey)),
                                    child: Text(
                                      'PLACE ORDER',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _color.value,
                                        fontSize: 17,
                                        fontFamily: 'MazzardLight',
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: 50,
                              child: AnimatedBuilder(
                                animation: _placeOrder.view,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _opacity,
                                    child: CircularProgressIndicator(
                                      color: Colors.green,
                                    ),
                                  );
                                },
                                child: CircularProgressIndicator(
                                  color: Colors.green[600],
                                ),
                              ),
                            ),
                          ],
                        );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Consumer<CartModel>(builder: (context, model, child) {
                    int items = 0;
                    for (var plantL in model.plantLites) items += plantL.count;
                    if (items == 0)
                      return SizedBox();
                    else
                      return TextButton(
                          onPressed: () async {
                            context.loaderOverlay.show();
                            cart.removeAll();
                            await database.clearCart();
                            context.loaderOverlay.hide();
                          },
                          child: Text(
                            'Clear Cart',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'MazzardLight',
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ));
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
