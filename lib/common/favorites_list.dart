import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nurture/common/favorite_tile.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ListFavorites extends StatefulWidget {
  @override
  _ListFavoritesState createState() => _ListFavoritesState();
}

class _ListFavoritesState extends State<ListFavorites>
    with TickerProviderStateMixin {
  int _plantIndex = 0;
  late AnimationController _entry;
  late AnimationController _controller;
  late AnimationController _shaker;
  late Animation<EdgeInsets> _animateSize;
  late Animation<Color?> _animateColor;
  late Animation<Offset> _animateShake;

  final _left = Tween<Offset>(begin: Offset(-2, 0), end: Offset.zero);
  final _right = Tween<Offset>(begin: Offset(2, 0), end: Offset.zero);
  late Animation<Offset> left;
  late Animation<Offset> right;
  @override
  void initState() {
    _entry =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    left = _left
        .animate(CurvedAnimation(parent: _entry, curve: Curves.elasticOut));
    right = _right
        .animate(CurvedAnimation(parent: _entry, curve: Curves.elasticOut));
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
        reverseDuration: Duration(milliseconds: 500));
    _shaker =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _shaker.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          _shaker.reverse();
          break;
      }
    });
    _animateSize =
        Tween<EdgeInsets>(begin: EdgeInsets.all(40), end: EdgeInsets.all(20))
            .animate(CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 0.3, curve: Curves.easeIn)));
    _animateColor =
        ColorTween(begin: Colors.indigo.shade600, end: Colors.red.shade600)
            .animate(CurvedAnimation(
                parent: _controller,
                curve: Interval(0.2, 0.7, curve: Curves.ease)));
    _animateShake = Tween<Offset>(begin: Offset(0.0, 0), end: Offset(0.1, 0))
        .animate(CurvedAnimation(parent: _shaker, curve: Curves.elasticIn));
    super.initState();
  }

  @override
  void dispose() {
    _entry.dispose();
    _controller.dispose();
    _shaker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('favorites_list build');
    final database = Provider.of<DatabaseService>(context, listen: false);
    final plants = Provider.of<List<PlantReference>>(context, listen: true);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: database.getFavorites(),
        builder: (context, snapshot) {
          _entry.reset();
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              child: Container(
                width: double.infinity,
                height: double.infinity,
              ),
              baseColor: Colors.white,
              highlightColor: Colors.white38,
            );
          } else {
            if (snapshot.data!.exists && snapshot.hasData) {
              var _list = snapshot.data!.data()!.keys.toList();
              return StaggeredGridView.countBuilder(
                  staggeredTileBuilder: (index) =>
                      StaggeredTile.count(1, index == 0 ? 0.5 : 1),
                  crossAxisCount: 2,
                  itemCount: 2 + _list.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                          alignment: Alignment.center,
                          width: 300,
                          height: 150,
                          child: Text('Found ${_list.length} items'));
                    } else if (index == 1 + _list.length) {
                      return DragTarget<PlantReference>(onLeave: (_) {
                        _shaker.forward();
                        _controller.reverse();
                      }, onWillAccept: (_) {
                        _shaker.forward();
                        _controller.forward();
                        return true;
                      }, onAccept: (plant) async {
                        _controller.reverse();
                        await database
                            .removeFavorites(UserFavoriteAction(id: plant.id));
                      }, builder: (context, _, __) {
                        return AnimatedBuilder(
                          animation: _controller.view,
                          child: Container(
                            alignment: Alignment.center,
                            width: 300,
                            height: 300,
                            margin: EdgeInsets.all(40),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.indigo.shade600),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 100,
                            ),
                          ),
                          builder: (context, child) {
                            return SlideTransition(
                              position: _animateShake,
                              child: Container(
                                alignment: Alignment.center,
                                width: 300,
                                height: 300,
                                margin: _animateSize.value,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: _animateColor.value),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 100,
                                ),
                              ),
                            );
                          },
                        );
                      });
                    } else {
                      for (int i = 0; i < plants.length; i++) {
                        if (plants[i].id == _list[index - 1]) {
                          _plantIndex = i;
                          break;
                        }
                      }
                      _entry.forward();
                      return FavoriteTile(
                        plant: plants[_plantIndex],
                        key: ValueKey(plants[_plantIndex].id),
                      );
                    }
                  });
            } else {
              return Center(
                child: Text('No favorites added'),
              );
            }
          }
        });
  }
}
