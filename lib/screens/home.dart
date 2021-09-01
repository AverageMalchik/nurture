import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/UI/drawer_ui.dart';
import 'package:nurture/common/plants_list.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffold = GlobalKey<ScaffoldState>();

  void close() {
    _scaffold.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffebeaef),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () => _scaffold.currentState?.openDrawer(),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            CartIcon(),
          ],
        ),
        key: _scaffold,
        drawer: DrawerUI(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              Text(
                'Home.',
                style: TextStyle(
                  color: Colors.orange,
                  fontFamily: 'MazzardExtraBold',
                  fontSize: 70,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListPlants(),
            ],
          ),
        ),
      ),
    );
  }
}
