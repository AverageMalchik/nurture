import 'package:flutter/material.dart';
import 'package:nurture/common/my_plant_tile.dart';
import 'package:nurture/models/plant.dart';

class MyPlantsList extends StatefulWidget {
  final List<MyPlantreference> listMyPlant;
  MyPlantsList({required this.listMyPlant});
  @override
  _MyPlantsListState createState() => _MyPlantsListState();
}

class _MyPlantsListState extends State<MyPlantsList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _up;
  late Animation<Offset> _down;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    _up = Tween<Offset>(begin: Offset(0, 0.75), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _down = Tween<Offset>(begin: Offset(0, -0.75), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: ListView.builder(
          shrinkWrap: false,
          addAutomaticKeepAlives: true,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: widget.listMyPlant.length,
          itemBuilder: (context, index) {
            _controller.forward();
            return SlideTransition(
              position: index.isEven ? _up : _down,
              child: MyPlantTile(
                myPlant: widget.listMyPlant[index],
                index: index,
              ),
            );
          },
        ),
      ),
    );
  }
}
