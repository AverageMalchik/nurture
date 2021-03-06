import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/screens/cart.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Widget loadingShimmer() {
  return Shimmer.fromColors(
    child: Container(
      margin: EdgeInsets.all(10),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xffebeaef),
      ),
    ),
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade200,
  );
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
          if (snapshot.connectionState != ConnectionState.waiting) {
            if (snapshot.data!.exists && snapshot.hasData) {
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
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoaderOverlay(
                                    overlayOpacity: 0.7,
                                    overlayWidget: Center(
                                      child: Container(
                                          height: 200,
                                          width: 200,
                                          child: CircularProgressIndicator()),
                                    ),
                                    child: Cart(initialCount: _items),
                                  )));
                    },
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
          } else {
            return Stack(
              children: [
                IconButton(
                    iconSize: 30,
                    onPressed: () {},
                    icon: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black,
                    ))
              ],
            );
          }
        });
  }
}

class SWFOClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.arcToPoint(Offset(size.width, size.height),
        clockwise: false, radius: Radius.circular(20));
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class UnsplashDialog extends StatefulWidget {
  @override
  _UnsplashDialogState createState() => _UnsplashDialogState();
}

class _UnsplashDialogState extends State<UnsplashDialog> {
  var _response;
  // to get random image from unsplash, each time
  Future getRandomImage() async {
    try {
      _response = await http.get(Uri.parse(
          'https://api.unsplash.com/photos/random/?query=nature&client_id=_bJpqffJzTK2KduhJk7sOh5MTmx_stxEOiuZyAOpRDI'));
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return FutureBuilder(
      future: getRandomImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var jsonResponse =
              convert.jsonDecode(_response.body) as Map<String, dynamic>;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ),
                  CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        NetworkImage(jsonResponse['urls']['small']),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () async {
                      await database.addPhotoURL(
                          UserPhotoReference(jsonResponse['urls']['small']));
                    },
                    icon: Icon(Icons.check),
                  ),
                  IconButton(
                      onPressed: () => setState(() {}),
                      icon: Icon(Icons.swap_horiz_rounded))
                ],
              )
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class PageDots extends StatelessWidget {
  final bool focus;
  PageDots({required this.focus});
  @override
  Widget build(BuildContext context) {
    return !focus
        ? Container(
            margin: EdgeInsets.all(5),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          )
        : Container(
            margin: EdgeInsets.all(5),
            width: 21,
            height: 7,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3.5)),
                color: Colors.blueGrey),
          );
  }
}

class RoundFeatures extends StatelessWidget {
  final int index;
  final String feature;
  RoundFeatures({required this.index, required this.feature});
  final listImages = [
    Positioned(
      top: -20,
      child: Image.asset(
        'assets/water.png',
        height: 100,
        width: 100,
      ),
    ),
    Positioned(
      top: 7,
      child: Image.asset(
        'assets/care.png',
        height: 50,
        width: 50,
      ),
    ),
    Positioned(
      top: 5,
      child: Image.asset(
        'assets/sun.png',
        height: 50,
        width: 50,
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(15),
      alignment: Alignment.center,
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          listImages[index],
          Positioned(
            bottom: 10,
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'MazzardLight',
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.grey[200],
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 1,
                    offset: Offset(-0.5, -0.5),
                  ),
                  Shadow(
                    color: Colors.black,
                    blurRadius: 1,
                    offset: Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 180,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 3),
                blurRadius: 2,
                color: Colors.grey.shade400)
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/google_icon.png',
            height: 25,
            width: 25,
          ),
          SizedBox(
            width: 15,
          ),
          Text(
            'Sign in with Google',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontFamily: 'MazzardLight',
              fontWeight: FontWeight.w900,
            ),
          )
        ],
      ),
    );
  }
}

class MenuIcon extends StatefulWidget {
  final Color baseColor;
  MenuIcon({required this.baseColor});
  @override
  _MenuIconState createState() => _MenuIconState();
}

class _MenuIconState extends State<MenuIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _icon;
  // late Animation _gradient;

  @override
  void initState() {
    _icon = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _icon.forward();
    _icon.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    _icon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _icon.view,
      child: SizedBox(),
      builder: (context, child) {
        return RotationTransition(
            turns: _icon.view,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  // margin: EdgeInsets.fromLTRB(20, 20, 10, 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          // _chooseBaseColor(widget.baseColor),
                          _chooseBaseColor(widget.baseColor),
                          _chooseBaseColor(widget.baseColor),
                          _chooseDarkColor(widget.baseColor),
                        ]),
                  ),
                ),
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff333333),
                  ),
                ),
              ],
            ));
      },
    );
  }

  Color _chooseBaseColor(Color baseColor) {
    if (baseColor == Colors.green) {
      return Colors.lightGreen;
    } else if (baseColor == Colors.black) {
      return Colors.black26;
    } else if (baseColor == Colors.orange) {
      return Colors.orange.shade300;
    } else if (baseColor == Colors.blue) {
      return Colors.blue.shade300;
    } else {
      return Colors.red.shade400;
    }
  }

  Color _chooseDarkColor(Color baseColor) {
    if (baseColor == Colors.green) {
      return Colors.green.shade600;
    } else if (baseColor == Colors.black) {
      return Colors.black;
    } else if (baseColor == Colors.orange) {
      return Colors.orange.shade900;
    } else if (baseColor == Colors.blue) {
      return Colors.blue.shade900;
    } else {
      return Colors.red.shade900;
    }
  }
}

const textInputDecoration = InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.all(20),
  labelText: 'Username',
  floatingLabelBehavior: FloatingLabelBehavior.always,
  fillColor: Colors.white,
  filled: true,
  disabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 2)),
  enabledBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 2)),
  focusedBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
  errorBorder:
      OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
);
