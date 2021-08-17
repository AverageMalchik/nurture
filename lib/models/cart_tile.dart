import 'package:flutter/material.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CartTile extends StatefulWidget {
  final PlantReference plant;
  final int count;

  CartTile({
    required this.plant,
    required this.count,
  });

  @override
  _CartTileState createState() => _CartTileState();
}

class _CartTileState extends State<CartTile>
    with SingleTickerProviderStateMixin {
  late Image _leading = Image.network(
    widget.plant.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null)
        return child;
      else {
        return SizedBox();
      }
    },
    fit: BoxFit.fill,
  ); //dimensions are 92x92

  late AnimationController _controller;
  late Animation<Offset> _reveal;

  // Tween<Offset> _offsetR = Tween<Offset>(begin: Offset.zero, end: Offset(5, 0));
  // Tween<Offset> _offsetL =
  //     Tween<Offset>(begin: Offset.zero, end: Offset(-5, 0));
  // CurveTween _curve = CurveTween(curve: Curves.easeIn);

  @override
  void initState() {
    print('cart_tile initState');
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _reveal = Tween<Offset>(begin: Offset.zero, end: Offset(0.76, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('entered cart_tile build');
    final database = Provider.of<DatabaseService>(context, listen: true);
    return Stack(
      children: [
        Container(
          height: 112,
          width: 400,
          // margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    (widget.plant.pricing * widget.count).toString(),
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
                    width: 27,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    width: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0.5)),
                  ),
                  Container(
                    width: 27,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black),
                  ),
                ],
              ))
            ],
          ),
        ),
        Positioned(
          top: 15,
          left: 10,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onTap: () async {
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

  /*Widget basic(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return Stack(
      children: [
        Container(
          height: 112,
          width: 400,
          // margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    (widget.plant.pricing * widget.count).toString(),
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
                    width: 27,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    width: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0.5)),
                  ),
                  Container(
                    width: 27,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black),
                  ),
                ],
              ))
            ],
          ),
        ),
        Positioned(
          top: 15,
          left: 10,
          child: _loading
              ? Shimmer.fromColors(
                  child: Container(
                    height: 92,
                    width: 92,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  ),
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade200)
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: GestureDetector(
                        onTap: () async {
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
  }*/
}
