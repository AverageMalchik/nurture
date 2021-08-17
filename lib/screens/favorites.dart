import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/models/drawer_model.dart';
import 'package:nurture/models/favorites_list.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>
    with SingleTickerProviderStateMixin {
  var _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print('favorites build');
    final database = Provider.of<DatabaseService>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        drawer: DrawerModel(),
        key: _scaffold,
        appBar: AppBar(
          title: Text(
            'Favorites',
            style: TextStyle(color: Colors.black),
          ),
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
              SizedBox(
                height: 10,
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 700,
                  maxWidth: 400,
                ),
                child: StreamProvider<List<PlantReference>>.value(
                  value: database.plantReferenceStream(),
                  initialData: <PlantReference>[],
                  builder: (context, _) {
                    return ListFavorites();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
