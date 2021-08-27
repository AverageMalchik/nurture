import 'package:flutter/material.dart';
import 'package:nurture/models/cart_model.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class CartTile extends StatefulWidget {
  int? index;
  final Key? key;
  final PlantReference plant;
  final int count;
  final Function(BuildContext, String) onRemove;
  final Animation<double>? animation;

  CartTile(
      {this.index,
      this.key,
      this.animation,
      required this.plant,
      required this.count,
      required this.onRemove});

  @override
  _CartTileState createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> with TickerProviderStateMixin {
  late double _opacity;
  late int _count;
  late Image _leading = Image.network(
    widget.plant.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null)
        return child;
      else {
        return Shimmer.fromColors(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(15)),
            ),
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade200);
      }
    },
    fit: BoxFit.fill,
  ); //dimensions are 92x92

  late AnimationController _controller;
  late AnimationController _change;
  late Animation<Offset> _reveal;

  List<Text> stackList = [Text('1'), Text('2')];

  CurveTween _curve = CurveTween(curve: Curves.elasticOut);

  @override
  void initState() {
    print('inside cart_tile initState ${widget.plant.id}');
    _count = widget.count;
    _opacity = _count == 1 ? 1.0 : 0.5;
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 500));
    _change =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _change.forward();
    _reveal = Tween<Offset>(begin: Offset.zero, end: Offset(0.76, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _change.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'inside cart_tile build ${widget.plant.name} with index ${widget.index}');
    if (widget.animation == null) {
      return basic(context);
    } else {
      return SizeTransition(
        sizeFactor: widget.animation!.drive(_curve),
        child: basicClose(context),
      );
    }
  }

  Widget basic(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: false);
    final database = Provider.of<DatabaseService>(context, listen: false);
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          height: 112,
          width: 400,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 91,
                width: 92,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.plant.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    widget.plant.category,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  FadeTransition(
                    opacity: _change.view,
                    child: Text(
                      '\$' + (widget.plant.pricing * _count).toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () async {
                        _change.reset();
                        cart.edit(widget.plant, widget.index!, _count - 1);
                        setState(() {
                          _opacity = 1.0;
                          --_count;
                          _change.forward();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 24,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                                width: 1,
                                color: _count == 2
                                    ? Colors.black
                                    : Colors.white38)),
                        child: Icon(
                          Icons.remove_rounded,
                          color: _count == 2 ? Colors.black : Colors.white38,
                          size: 18,
                        ),
                      )),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    width: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0.5)),
                    child: IndexedStack(
                      alignment: Alignment.center,
                      index: _count - 1,
                      children: stackList,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_count == 1) {
                        _change.reset();

                        cart.edit(widget.plant, widget.index!, _count + 1);
                        setState(() {
                          ++_count;
                          _opacity = 0.5;
                          _change.forward();
                        });
                      }
                    },
                    child: AnimatedOpacity(
                      opacity: _opacity,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                      child: Container(
                        alignment: Alignment.center,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade400,
                                  offset: Offset(0, 5),
                                  blurRadius: 3)
                            ]),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onTap: () async {
                    _controller.reverse();
                    await widget.onRemove(context, widget.plant.id);
                    await database
                        .removeCart(UserCartAction(id: widget.plant.id));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.red[600],
                    width: 92,
                    height: 91,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                        SizedBox(
                          width: 2,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: _reveal,
                child: Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        offset: Offset(3, 3),
                        blurRadius: 4,
                        color: Colors.grey.shade300)
                  ], borderRadius: BorderRadius.circular(15)),
                  child: ClipRRect(
                    child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (!details.primaryVelocity!.isNegative)
                            _controller.forward();
                        },
                        child: _leading),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 15,
          left: 10 + 80,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity!.isNegative) _controller.reverse();
            },
            onTap: () {
              _controller.reverse();
            },
            child: Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.transparent),
            ),
          ),
        )
      ],
    );
  }

  Widget basicClose(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          height: 112,
          width: 400,
          // margin: EdgeInsets.symmetric(vertical: 5),
          // padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 91,
                width: 92,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.plant.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    widget.plant.category,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '\$' + (widget.plant.pricing * _count).toString(),
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 24,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            width: 1,
                            color:
                                _count == 2 ? Colors.black : Colors.white38)),
                    child: Icon(
                      Icons.remove_rounded,
                      color: _count == 2 ? Colors.black : Colors.white38,
                      size: 18,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    width: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0.5)),
                    child: Text(_count.toString()),
                  ),
                  Opacity(
                    opacity: _count == 2 ? 0.5 : 1.0,
                    child: Container(
                      alignment: Alignment.center,
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade400,
                                offset: Offset(0, 5),
                                blurRadius: 3)
                          ]),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              alignment: Alignment.center,
              color: Colors.red[600],
              width: 92,
              height: 91,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(
                    width: 2,
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10 + 70,
          child: Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: Offset(3, 3),
                  blurRadius: 4,
                  color: Colors.grey.shade300)
            ], borderRadius: BorderRadius.circular(15)),
            child: ClipRRect(
              child: _leading,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        )
      ],
    );
  }
}
