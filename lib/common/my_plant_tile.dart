import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/screens/my_plants.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MyPlantTile extends StatefulWidget {
  final MyPlantreference myPlant;
  final int index;
  MyPlantTile({required this.myPlant, required this.index});
  @override
  _MyPlantTileState createState() => _MyPlantTileState();
}

class _MyPlantTileState extends State<MyPlantTile>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late AnimationController _size;
  late AnimationController _errorOpacity;
  late Animation<double> _error;
  late Animation<double> _glow;
  late Animation<double> _radius1;
  late Animation<double> _radius2;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  late bool dead;
  late String due;
  late String prev;
  late bool safe;
  late int requiredforUnsafe;
  late int actions;
  late int offset;

  @override
  void initState() {
    offset = widget.myPlant.plant.water != 'Frequent' ? 60 : 30;
    print(widget.myPlant.time + " vs " + DateTime.now().toString());
    safe = DateTime.parse(widget.myPlant.time).isAfter(DateTime.now());
    prev = widget.myPlant.last;
    due = widget.myPlant.time;
    requiredforUnsafe = !safe ? checkTime() : 0;
    requiredforUnsafe =
        requiredforUnsafe.isNegative ? -requiredforUnsafe : requiredforUnsafe;
    if (safe) actions = 0;
    dead = actions > (widget.myPlant.plant.water != 'Frequent' ? 12 : 6);
    print(requiredforUnsafe.toString() + ' with offset: $offset');

    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _controller.repeat(reverse: true);
    _size = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: widget.myPlant.plant.water == 'Frequent' ? 2500 : 5000),
      reverseDuration: Duration(milliseconds: 500),
    );
    _errorOpacity = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _error = Tween<double>(begin: !safe ? 1.0 : 0.0, end: 0.0)
        .animate(CurvedAnimation(parent: _errorOpacity, curve: Curves.easeIn));
    _glow = Tween<double>(begin: 5, end: 10)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    _color1 = ColorTween(begin: Color(0xff00f6eb), end: Color(0xff083936))
        .animate(CurvedAnimation(parent: _size, curve: Interval(0, 0.1)));
    _color2 = ColorTween(begin: Color(0xff083936), end: Color(0xff00f6eb))
        .animate(CurvedAnimation(parent: _size, curve: Interval(0.85, 1.0)));
    _radius1 = Tween<double>(begin: 50, end: 150).animate(_size);
    _radius2 = Tween<double>(begin: 50, end: 150)
        .animate(CurvedAnimation(parent: _size, curve: Interval(0.3, 1.0)));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _size.dispose();
    super.dispose();
  }

  //check how many required before
  int checkTime() {
    var dueTime = DateTime.parse(due);
    dueTime = DateTime(dueTime.year, dueTime.month, dueTime.day, dueTime.hour,
        dueTime.minute, dueTime.second);
    var now = DateTime.now();
    now = DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    var lastTime = DateTime.parse(prev);
    lastTime = DateTime(lastTime.year, lastTime.month, lastTime.day,
        lastTime.hour, lastTime.minute, lastTime.second);
    var difference1 = dueTime.difference(now).inMinutes;
    var difference2 = dueTime.difference(lastTime).inMinutes;
    actions = -(difference1 / offset).ceil();
    if (!difference2.isNegative)
      return (difference1 / offset).ceil();
    else
      return (difference1 / offset).ceil() - (difference2 / offset).ceil();
  }

  //update due
  String updateTime() {
    print('inside updateTime');
    var dueTime = DateTime.parse(due)
        .add(Duration(minutes: (actions + 1) * offset))
        .toString();
    return dueTime;
  }

  //used to show time elapsed in hrs mins format
  String displayTimeElapsed(DateTime previous) {
    previous = DateTime(previous.year, previous.month, previous.day,
        previous.hour, previous.minute, previous.second);
    var now = DateTime.now();
    now = DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    var difference = now.difference(previous).inMinutes;
    if (difference >= 60)
      return '${(difference / 60).floor()} hours';
    else if (difference < 60 && difference >= 2)
      return '$difference minutes';
    else
      return 'a few moments';
  }

  @override
  Widget build(BuildContext context) {
    print('inside my_plant_tile build');
    final inherited = MyInheritedList.of(context);
    inherited.addList(widget.myPlant);
    if (!dead)
      return alive(context);
    else
      return greyDead(context);
  }

  Widget alive(BuildContext context) {
    final inherited = MyInheritedList.of(context);
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
                color: widget.index.isEven
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
                        color: widget.index.isEven
                            ? Color(0xff4a956c)
                            : Color(0xff38a07b))
                  ],
                  gradient: LinearGradient(
                      colors: widget.index.isEven
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
                    image:
                        AssetImage('assets/${widget.myPlant.plant.name}.png'),
                  )),
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
                widget.myPlant.count.toString(),
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Positioned(
            top: 330,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.myPlant.plant.category,
                style: TextStyle(fontSize: 15, color: Colors.green),
              ),
            ),
          ),
          Positioned(
            top: 350,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.myPlant.plant.name,
                style: TextStyle(
                    fontSize: 25, color: Colors.white, letterSpacing: 1),
              ),
            ),
          ),
          Positioned(
            top: 380,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Purchased on ${DateFormat('dd/MM/yy').format(DateTime.parse(widget.myPlant.purchase))}',
                style: TextStyle(color: Colors.greenAccent[700], fontSize: 12),
              ),
            ),
          ),
          Positioned(
            top: 395,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: AnimatedBuilder(
                animation: _size.view,
                builder: (context, _) {
                  return Text(
                    'Last watered ' +
                        displayTimeElapsed(
                            DateTime.parse(inherited.list[widget.index].last)) +
                        ' ago',
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(left: 75),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Color(0xff083936),
                      shape: BoxShape.circle,
                    )),
                AnimatedBuilder(
                    animation: _size.view,
                    builder: (context, child) {
                      return Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 75),
                          width: !safe ? _radius1.value : 150,
                          height: !safe ? _radius1.value : 150,
                          decoration: BoxDecoration(
                            color: Color(0xff00f6eb),
                            shape: BoxShape.circle,
                          ));
                    }),
                //water lock animation
                GestureDetector(
                  onLongPress: () {
                    if (!safe) _size.forward();
                    if (requiredforUnsafe == 0) _errorOpacity.forward();
                  },
                  onLongPressUp: () async {
                    if (_size.isCompleted) {
                      prev = DateTime.now().toString();
                      inherited.editList(
                          widget.index,
                          MyPlantreference(
                              last: prev,
                              count: widget.myPlant.count,
                              plant: widget.myPlant.plant,
                              purchase: widget.myPlant.purchase,
                              time: due));
                      --requiredforUnsafe;
                      if (requiredforUnsafe >= 0) {
                        _size.reverse();
                        return;
                      }
                      print('2nd part');
                      due = updateTime();
                      inherited.editList(
                          widget.index,
                          MyPlantreference(
                              last: prev,
                              count: widget.myPlant.count,
                              plant: widget.myPlant.plant,
                              purchase: widget.myPlant.purchase,
                              time: due));
                    } else {
                      _size.reverse();
                      if (_errorOpacity.isCompleted ||
                          _errorOpacity.isAnimating) _errorOpacity.reset();
                    }
                  },
                  //main center circle
                  child: AnimatedBuilder(
                      animation: _controller.view,
                      child: Container(
                          margin: EdgeInsets.only(left: 75),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xff00f6eb),
                            shape: BoxShape.circle,
                          )),
                      builder: (context, child) {
                        return Container(
                            margin: EdgeInsets.only(left: 75),
                            width: _radius2.value,
                            height: _radius2.value,
                            decoration: BoxDecoration(
                              color: _size.value <= 0.85
                                  ? _color1.value
                                  : /*Color(0xff00f6eb)*/ _color2.value,
                              boxShadow: [
                                BoxShadow(
                                    color: !_size.isAnimating
                                        ? Color(0xff00cdf6)
                                        : Colors.transparent,
                                    spreadRadius: _glow.value,
                                    blurRadius: _glow.value)
                              ],
                              shape: BoxShape.circle,
                            ));
                      }),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 135,
            right: 30,
            child: FadeTransition(
              opacity: _error,
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

  Widget greyDead(BuildContext context) {
    final inherited = MyInheritedList.of(context);
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
                color: Colors.grey[300]),
          ),
          Positioned(
            top: 20,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(20),
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 15),
                      blurRadius: 10,
                      color: Colors.grey.shade700)
                ],
                image: DecorationImage(
                    image:
                        AssetImage('assets/${widget.myPlant.plant.name}.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.grey.shade400, BlendMode.saturation)),
                gradient: LinearGradient(colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade900,
                ], begin: Alignment.topRight, end: Alignment.bottomLeft),
                shape: BoxShape.circle,
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
                widget.myPlant.count.toString(),
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Positioned(
            top: 330,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.myPlant.plant.category,
                style: TextStyle(fontSize: 15, color: Colors.white54),
              ),
            ),
          ),
          Positioned(
            top: 350,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.myPlant.plant.name,
                style: TextStyle(
                    fontSize: 25, color: Colors.black, letterSpacing: 1),
              ),
            ),
          ),
          Positioned(
            top: 380,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Purchased on ${DateFormat('dd/MM/yy').format(DateTime.parse(widget.myPlant.purchase))}',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
          Positioned(
            top: 395,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: AnimatedBuilder(
                animation: _size.view,
                builder: (context, _) {
                  return Text(
                    'Last watered ' +
                        displayTimeElapsed(
                            DateTime.parse(inherited.list[widget.index].last)) +
                        ' ago',
                    style: TextStyle(fontSize: 10, color: Colors.red),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                    margin: EdgeInsets.only(left: 75),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Color(0xff083936),
                      shape: BoxShape.circle,
                    )),
                Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 75),
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    )),
                //water lock animation
                AnimatedBuilder(
                    animation: _controller.view,
                    child: Container(
                        margin: EdgeInsets.only(left: 75),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          shape: BoxShape.circle,
                        )),
                    builder: (context, child) {
                      return Container(
                          margin: EdgeInsets.only(left: 75),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade600,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.orange.shade800,
                                  spreadRadius: _glow.value,
                                  blurRadius: _glow.value)
                            ],
                            shape: BoxShape.circle,
                          ));
                    }),
              ],
            ),
          ),
          Positioned(
            bottom: 135,
            right: 30,
            child: Icon(
              Icons.error_rounded,
              color: Colors.red[600],
              size: 30,
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
