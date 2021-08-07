import 'package:flutter/material.dart';
import 'package:nurture/models/drawer_model.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      drawer: DrawerModel(),
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You have reached home.'),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 10,
              ),

              // ElevatedButton(
              //     onPressed: () => Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => Profile())),
              //     child: Text('Profile'))
            ],
          ),
          Positioned(
              left: 10,
              top: 20,
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffold.currentState?.openDrawer(),
              )),
        ],
      ),
    );
  }
}
