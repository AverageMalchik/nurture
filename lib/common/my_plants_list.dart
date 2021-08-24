import 'package:flutter/material.dart';
import 'package:nurture/common/my_plant_tile.dart';

class MyPlantsList extends StatefulWidget {
  final Map<String, dynamic> myPlantsMap;
  MyPlantsList({required this.myPlantsMap});
  @override
  _MyPlantsListState createState() => _MyPlantsListState();
}

class _MyPlantsListState extends State<MyPlantsList>
    with SingleTickerProviderStateMixin {
  final _state = GlobalKey<AnimatedListState>();

  CurveTween _curve = CurveTween(curve: Curves.elasticOut);
  Tween<Offset> _up = Tween<Offset>(begin: Offset(0, 0.75), end: Offset.zero);
  Tween<Offset> _down =
      Tween<Offset>(begin: Offset(0, -0.75), end: Offset.zero);

  List<MyPlantTile> listMyPlantTile = [];

  void addtoList() {
    widget.myPlantsMap.forEach((key, value) {
      if (key.length == 20) {
        listMyPlantTile.add(MyPlantTile(
          time: value,
          count: widget.myPlantsMap[key + 'count'],
          id: key,
          onRemove: removefromList,
        ));
        _state.currentState!.insertItem(listMyPlantTile.length - 1);
      }
    });
  }

  void removefromList(int index) {
    var temp = listMyPlantTile[index];
    listMyPlantTile.removeAt(index);
    _state.currentState!.removeItem(index, (context, animation) {
      return FadeTransition(
        opacity: animation,
        child: MyPlantTile(
            index: index,
            time: temp.time,
            count: temp.count,
            id: temp.id,
            animation: animation),
      );
    }, duration: Duration(milliseconds: 500));
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      addtoList();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: AnimatedList(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          key: _state,
          itemBuilder: (context, index, animation) {
            return SlideTransition(
              position: index.isEven
                  ? animation.drive(_curve).drive(_up)
                  : animation.drive(_curve).drive(_down),
              child: addIndex(index),
            );
          },
        ),
      ),
    );
  }

  Widget addIndex(int index) {
    listMyPlantTile[index].index = index;
    return listMyPlantTile[index];
  }
}
