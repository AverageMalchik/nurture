import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/UI/drawer_ui.dart';
import 'package:nurture/common/favorites_list.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>
    with SingleTickerProviderStateMixin {
  final _scaffold = GlobalKey<ScaffoldState>();

  void close() {
    _scaffold.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    print('favorites build');
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: DrawerUI(),
        key: _scaffold,
        appBar: AppBar(
          // title: Text(
          //   'Favorites',
          //   style: TextStyle(color: Colors.black),
          // ),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () => _scaffold.currentState!.openDrawer(),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            CartIcon(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Favorites',
                    style: TextStyle(
                      color: Colors.redAccent.shade400,
                      fontFamily: 'MazzardExtraBold',
                      fontSize: 40,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 600,
                  maxWidth: 400,
                ),
                child: ListFavorites(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
