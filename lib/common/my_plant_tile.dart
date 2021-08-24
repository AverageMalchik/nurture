import 'package:flutter/material.dart';
import 'package:nurture/models/plant.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MyPlantTile extends StatefulWidget {
  int? index;
  final Function(int)? onRemove;
  final Animation? animation;
  final String time;
  final int count;
  final String id;
  MyPlantTile(
      {this.onRemove,
      this.animation,
      required this.time,
      required this.count,
      required this.id,
      this.index});
  @override
  _MyPlantTileState createState() => _MyPlantTileState();
}

class _MyPlantTileState extends State<MyPlantTile>
    with SingleTickerProviderStateMixin {
  int index = 0;

  late AnimationController _translation;
  late Animation<Offset> _translate;
  late Animation<double> _rotate;

  @override
  void initState() {
    _translation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _translate = Tween<Offset>(begin: Offset.zero, end: Offset(0, 1.3)).animate(
        CurvedAnimation(parent: _translation, curve: Interval(0.0, 1.0)));
    _rotate = Tween<double>(begin: 0.0, end: 0.25).animate(_translation);
    super.initState();
  }

  @override
  void dispose() {
    _translation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('inside my_plant_tile build');
    if (widget.animation == null)
      return basic(context);
    else
      return basicClose(context);
  }

  Widget basic(BuildContext context) {
    final plants = Provider.of<List<PlantReference>>(context, listen: true);
    plants.forEach((element) {
      if (element.id == widget.id) index = plants.indexOf(element);
    });
    print(widget.time);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: 300,
            height: 650,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: widget.index!.isEven
                    ? Color(0xff94db93)
                    : Color(0xff77d6b4)),
          ),
          Positioned(
            top: 20,
            child: Container(
              margin: EdgeInsets.all(20),
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 15),
                        blurRadius: 10,
                        color: widget.index!.isEven
                            ? Color(0xff4a956c)
                            : Color(0xff38a07b))
                  ],
                  gradient: LinearGradient(
                      colors: widget.index!.isEven
                          ? [
                              Color(0xff7ec57d),
                              Color(0xff4a956c),
                            ]
                          : [
                              Color(0xff79d5aa),
                              Color(0xff38a07b),
                            ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/${plants[index].name}.png'),
                  )),
            ),
          ),
          Positioned(
            right: 30,
            top: 200,
            child: AnimatedBuilder(
              animation: _translation.view,
              builder: (context, child) {
                return Opacity(
                  opacity: _translation.value,
                  child: SlideTransition(
                    position: _translate,
                    child: RotationTransition(
                      turns: _rotate,
                      child: Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 265,
            child: GestureDetector(
              onTap: () async {
                widget.onRemove!(widget.index!);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.transparent, shape: BoxShape.circle),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 200,
            child: GestureDetector(
              onLongPress: () => _translation.forward(),
              onTap: () => _translation.reverse(),
              child: Container(
                alignment: Alignment.center,
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white70,
                ),
                child: Text(
                  widget.count.toString(),
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          Positioned(
            top: 330,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                plants[index].category,
                style: TextStyle(fontSize: 15, color: Colors.green),
              ),
            ),
          ),
          Positioned(
            top: 360,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                plants[index].name,
                style: TextStyle(
                    fontSize: 25, color: Colors.white, letterSpacing: 1),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            child: Container(
                margin: EdgeInsets.only(left: 75),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Color(0xff083936),
                  shape: BoxShape.circle,
                )),
          ),
          Positioned(
            bottom: 135,
            right: 30,
            child: Opacity(
              opacity: DateTime.now().isBefore(DateTime.parse(widget.time))
                  ? 0.0
                  : 1.0,
              child: Icon(
                Icons.error_rounded,
                color: Colors.red[600],
                size: 30,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget basicClose(BuildContext context) {
    final plants = Provider.of<List<PlantReference>>(context, listen: true);
    plants.forEach((element) {
      if (element.id == widget.id) index = plants.indexOf(element);
    });
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: 300,
            height: 650,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: widget.index!.isEven
                    ? Color(0xff94db93)
                    : Color(0xff77d6b4)),
          ),
          Positioned(
            top: 20,
            child: Container(
              margin: EdgeInsets.all(20),
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 15),
                        blurRadius: 10,
                        color: widget.index!.isEven
                            ? Color(0xff4a956c)
                            : Color(0xff38a07b))
                  ],
                  gradient: LinearGradient(
                      colors: widget.index!.isEven
                          ? [
                              Color(0xff7ec57d),
                              Color(0xff4a956c),
                            ]
                          : [
                              Color(0xff79d5aa),
                              Color(0xff38a07b),
                            ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/${plants[index].name}.png'),
                  )),
            ),
          ),
          Positioned(
            right: 30,
            top: 265,
            child: Container(
              width: 50,
              height: 50,
              decoration:
                  BoxDecoration(color: Colors.red[600], shape: BoxShape.circle),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 200,
            child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white70,
              ),
              child: Text(
                widget.count.toString(),
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Positioned(
            top: 330,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                plants[index].category,
                style: TextStyle(fontSize: 15, color: Colors.green),
              ),
            ),
          ),
          Positioned(
            top: 360,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                plants[index].name,
                style: TextStyle(
                    fontSize: 25, color: Colors.white, letterSpacing: 1),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            child: Container(
                margin: EdgeInsets.only(left: 75),
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Color(0xff083936),
                  shape: BoxShape.circle,
                )),
          ),
          Positioned(
            bottom: 135,
            right: 30,
            child: Opacity(
              opacity: DateTime.now().isBefore(DateTime.parse(widget.time))
                  ? 0.0
                  : 1.0,
              child: Icon(
                Icons.error_rounded,
                color: Colors.red[600],
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
