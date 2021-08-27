import 'package:flutter/material.dart';
import 'package:nurture/models/plant.dart';
// import 'package:flutter/physics.dart';
import 'package:shimmer/shimmer.dart';

class FavoriteTile extends StatefulWidget {
  final PlantReference plant;
  FavoriteTile({required this.plant});
  @override
  _FavoriteTileState createState() => _FavoriteTileState();
}

class _FavoriteTileState extends State<FavoriteTile>
    with TickerProviderStateMixin {
  late Image _cover;
  bool _loading = true;

  late AnimationController _controller;
  late Animation _animateSize;
  late Animation _animateOpacity;

  // late AnimationController _spring;
  // late Animation _animateSpring;
  // double _positiondx = 0;
  // double _positiondy = 0;

  late AnimationController _shake;
  late Animation<Offset> _shakeChild;

  @override
  void initState() {
    _cover = Image.network(
      widget.plant.cover,
      fit: BoxFit.fill,
    );
    _cover.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }));
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
        reverseDuration: Duration(milliseconds: 500));
    _animateSize = Tween<double>(begin: 160, end: 100).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.2, 0.8, curve: Curves.ease)));
    _animateOpacity = Tween<double>(begin: 1.0, end: .75).animate(
        CurvedAnimation(
            parent: _controller,
            curve: Interval(0.0, 0.5, curve: Curves.ease)));
    // _spring =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    // _spring.addListener(() {
    //   _positiondx = _animateSpring.value.dx;
    //   _positiondy = _animateSpring.value.dy;
    // });
    _shake =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _shake.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          _shake.reverse();
          break;
      }
    });
    _shakeChild = Tween<Offset>(begin: Offset.zero, end: Offset(0.1, 0))
        .animate(CurvedAnimation(parent: _shake, curve: Curves.elasticIn));

    super.initState();
  }

  @override
  void dispose() {
    // _spring.dispose();
    _shake.dispose();
    _controller.dispose();
    super.dispose();
  }

  //creating spring animation
  // void _springAnimation(Offset pixelsPerSecond, Size size) {
  //   _animateSpring = _spring.drive(Tween<Offset>(
  //       begin: Offset(_positiondx, _positiondy), end: Offset.zero));

  //   final unitsPerSecondX = pixelsPerSecond.dx / size.width;
  //   final unitsPerSecondY = pixelsPerSecond.dy / size.height;
  //   final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
  //   final unitVelocity = unitsPerSecond.distance;

  //   const spring = SpringDescription(
  //     mass: 30,
  //     stiffness: 1,
  //     damping: 1,
  //   );

  //   final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

  //   _spring.animateWith(simulation);
  // }

  @override
  Widget build(BuildContext context) {
    print('favorite_tile build');
    // var size = MediaQuery.of(context).size;
    return _loading
        ? Shimmer.fromColors(
            child: Container(
              margin: EdgeInsets.all(20),
              width: 300,
              height: 300,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              color: Colors.black,
            ),
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade200)
        : LongPressDraggable<PlantReference>(
            // ignore: deprecated_member_use
            dragAnchor: DragAnchor.child,
            onDragStarted: () => _controller.forward(),
            // onDragUpdate: (details) {
            //   _positiondx += details.delta.dx / (size.width / 2);
            //   _positiondy += details.delta.dy / (size.height / 2);
            // },
            onDragCompleted: () => _controller.reverse(),
            onDraggableCanceled: (velocity, offset) {
              _shake.forward();
              _controller.reverse();
              // _springAnimation(velocity.pixelsPerSecond, size);
            },
            data: widget.plant,
            feedback: feedback(),
            childWhenDragging: SizedBox(),
            child: SlideTransition(
              position: _shakeChild,
              child: Container(
                margin: EdgeInsets.all(20),
                height: 300,
                width: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _cover,
                ),
              ),
            ),
          );
  }

  Widget feedback() {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (_, __) {
        return Opacity(
          opacity: _animateOpacity.value,
          child: Container(
            margin: EdgeInsets.all(20),
            height: _animateSize.value,
            width: _animateSize.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _cover,
            ),
          ),
        );
      },
    );
  }
}
