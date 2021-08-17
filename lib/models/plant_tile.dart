import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:nurture/UI/ui.dart';

class PlantTile extends StatefulWidget {
  final PlantReference plant;
  final int? count;
  PlantTile({required this.plant, this.count});

  @override
  _PlantTileState createState() => _PlantTileState();
}

class _PlantTileState extends State<PlantTile> with TickerProviderStateMixin {
  late Image _coverImage;
  bool _loading = true;
  bool _loadingCount = true;
  bool _focused = false;
  int _count = 0;
  late bool _inStock;
  ColorFilter _colorFilter =
      ColorFilter.mode(Colors.grey.shade900, BlendMode.saturation);

  late AnimationController _controller;
  late AnimationController _lottieController;
  late AnimationController _plus;
  late Animation<double> animation;
  late Animation<double> _animateSize;
  Color _endColor = Colors.deepPurple.shade400;

  @override
  void initState() {
    //check if product is in stock
    _inStock = widget.plant.stock >= 1 ? true : false;
    //controller for border glow animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _lottieController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800),
        reverseDuration: Duration(milliseconds: 500));
    _plus =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _coverImage = Image.network(
      widget.plant.cover,
      fit: BoxFit.contain,
    );
    _animateSize = Tween<double>(begin: 30, end: 25)
        .animate(CurvedAnimation(parent: _plus, curve: Curves.elasticIn));
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          _controller.reverse();
          break;
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _lottieController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          _focused = true;
          break;
        case AnimationStatus.dismissed:
          _focused = false;
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _plus.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          _endColor = _count == 2
              ? Colors.deepPurple.shade200
              : Colors.deepPurple.shade400;
          _plus.reverse();
          break;
      }
    });
    _coverImage.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }));
    super.initState();
  }

  @override
  void dispose() {
    _plus.dispose();
    _controller.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return !_loading
        ? Container(
            height: 300,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: _inStock
                      ? _coverImage
                      : ColorFiltered(
                          colorFilter: _colorFilter,
                          child: _coverImage,
                        ),
                ),
                FadeTransition(
                  opacity: animation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.deepPurple.shade100, BlendMode.modulate),
                      child: _coverImage,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(widget.plant.name),
                    _inStock
                        ? Text(widget.plant.pricing.toString())
                        : Text('Unavailable'),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
                //heart lottie
                Positioned(
                    top: 1,
                    right: 1,
                    child: StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                        stream: database.getFavorites(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              color: Colors.transparent,
                              width: 50,
                              height: 50,
                              child: Lottie.asset(
                                'assets/heart.json',
                                animate: false,
                              ),
                            );
                          } else {
                            if (snapshot.hasData) {
                              if (snapshot.data!
                                  .data()!
                                  .containsKey('${widget.plant.id}')) {
                                _lottieController.forward();
                              }
                            }
                            print('inside lottie streambuilder');
                            return GestureDetector(
                              onTap: () async {
                                if (_focused) {
                                  _lottieController.reverse();
                                  await database.removeFavorites(
                                      UserFavoriteAction(id: widget.plant.id));
                                } else {
                                  _lottieController.forward();
                                  await database.addFavorites(
                                      UserFavoriteAction(id: widget.plant.id));
                                }
                              },
                              child: Container(
                                color: Colors.transparent,
                                width: 50,
                                height: 50,
                                child: Lottie.asset(
                                  'assets/heart.json',
                                  repeat: false,
                                  controller: _lottieController,
                                ),
                              ),
                            );
                          }
                        })),
                Positioned(
                  top: 2,
                  left: 2,
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: database.getCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          _loadingCount = true;
                        } else {
                          _loadingCount = false;
                          if (snapshot.hasData) {
                            if (snapshot.data!
                                .data()!
                                .containsKey(widget.plant.id))
                              _count =
                                  snapshot.data!.data()!['${widget.plant.id}'];
                            else
                              _count = 0;
                          } else {
                            _count = 0;
                          }
                        }
                        _endColor = Colors.deepPurple.shade400;
                        return AnimatedSwitcher(
                          switchInCurve: Curves.easeInBack,
                          duration: Duration(milliseconds: 800),
                          child: _loadingCount
                              ? SizedBox()
                              : GestureDetector(
                                  onTap: _inStock
                                      ? (_count == 2
                                          ? null
                                          : () async {
                                              print('Button Clicked');
                                              _controller.forward();
                                              _plus.forward();
                                              ++_count;
                                              await database.addCart(
                                                  UserCartAction(
                                                      id: widget.plant.id,
                                                      amount: _count));
                                              print('Button Click Over');
                                            })
                                      : () {},
                                  child: AnimatedBuilder(
                                    animation: _plus.view,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Container(
                                        height: _animateSize.value,
                                        width: _animateSize.value,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: _count == 2
                                                ? Colors.deepPurple[200]
                                                : _endColor,
                                            shape: BoxShape.circle),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: -2,
                                              right: -2,
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.deepPurple[600],
                                                size: _animateSize.value *
                                                    26 /
                                                    30,
                                              ),
                                            ),
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size:
                                                  _animateSize.value * 26 / 30,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: _count == 2
                                              ? Colors.deepPurple[200]
                                              : Colors.deepPurple[400],
                                          shape: BoxShape.circle),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: -2,
                                            right: -2,
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.deepPurple[600],
                                              size: 26,
                                            ),
                                          ),
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      }),
                )
              ],
            ),
          )
        : loadingShimmer();
  }
}
