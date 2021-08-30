import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HeroPlant extends StatefulWidget {
  final PlantReference plant;
  final int count;
  HeroPlant({
    required this.count,
    required this.plant,
  });
  @override
  _HeroPlantState createState() => _HeroPlantState();
}

class _HeroPlantState extends State<HeroPlant> with TickerProviderStateMixin {
  late AnimationController _entry;
  late AnimationController _description;
  late AnimationController _press;
  late PageController _pageController;
  late Animation<double> _page;
  late Animation<double> _opacity;
  late Animation<Color?> _color;
  late bool _inStock;
  late List<String> _list;

  int _count = 0;

  @override
  void initState() {
    _list = [widget.plant.water, widget.plant.care, widget.plant.place];
    _countController.add(widget.count);
    _inStock = widget.plant.stock >= 2 ? true : false;
    _pageController = PageController(initialPage: 0);
    _entry = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 50));
    _description = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 200));
    _press =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _page = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _entry, curve: Curves.easeIn));
    _opacity = Tween<double>(begin: 0, end: 1).animate(_description);
    _color = ColorTween(begin: Colors.black, end: Colors.grey).animate(_press);
    Timer(Duration(milliseconds: 2000), () => _entry.forward());
    super.initState();
  }

  @override
  void dispose() {
    _indexController.close();
    _countController.close();
    _description.dispose();
    _entry.dispose();
    _pageController.dispose();
    super.dispose();
  }

  StreamController<int> _indexController = StreamController<int>();
  StreamController<int> _countController = StreamController<int>();

  PanelController _panelController = PanelController();

  final _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return SafeArea(
        child: Scaffold(
      key: _scaffold,
      backgroundColor: Color(0xffebe9ec),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            _entry.reverse();
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          CartIcon(),
        ],
      ),
      body: AnimatedBuilder(
        animation: _entry.view,
        child: SizedBox(),
        builder: (context, child) {
          return SlidingUpPanel(
            controller: _panelController,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 350,
                      width: 350,
                      // constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(75),
                            child: Container(
                              height: 400,
                              width: 400,
                              child: PageView(
                                controller: _pageController,
                                physics: BouncingScrollPhysics(),
                                onPageChanged: (index) {
                                  _indexController.add(index);
                                },
                                children: [
                                  Container(
                                    height: 400,
                                    width: 400,
                                    child: _inStock
                                        ? Hero(
                                            tag: 'hero${widget.plant.cover}',
                                            child: Image.network(
                                              widget.plant.cover,
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        : Hero(
                                            tag: 'hero${widget.plant.cover}',
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                  Colors.grey,
                                                  BlendMode.saturation),
                                              child: Image.network(
                                                widget.plant.cover,
                                                fit: BoxFit.contain,
                                              ),
                                            )),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 400,
                                    width: 400,
                                    child: _inStock
                                        ? Image.network(
                                            widget.plant.secondary,
                                            fit: BoxFit.contain,
                                            loadingBuilder:
                                                (context, child, progess) {
                                              if (progess == null)
                                                return child;
                                              else {
                                                return CircularProgressIndicator(
                                                  color: Colors.blueGrey,
                                                );
                                              }
                                            },
                                          )
                                        : ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                                Colors.grey,
                                                BlendMode.saturation),
                                            child: Image.network(
                                              widget.plant.secondary,
                                              fit: BoxFit.contain,
                                              loadingBuilder:
                                                  (context, child, progress) {
                                                if (progress == null)
                                                  return child;
                                                else {
                                                  return CircularProgressIndicator(
                                                    color: Colors.blueGrey,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                              right: 150,
                              bottom: 40,
                              child: FadeTransition(
                                opacity: _page,
                                child: StreamBuilder<int>(
                                    stream: _indexController.stream,
                                    initialData: 0,
                                    builder: (context, snapshot) {
                                      return Row(
                                        children: [
                                          for (int i = 0; i < 2; i++)
                                            if (i == snapshot.data)
                                              PageDots(focus: true)
                                            else
                                              PageDots(focus: false)
                                        ],
                                      );
                                    }),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                FadeTransition(
                  opacity: _page,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //insert 3 rounded containers: water,care,indoor/outdoor
                      for (int i = 0; i < 3; i++)
                        RoundFeatures(
                          index: i,
                          feature: _list[i],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            boxShadow: _entry.isCompleted
                ? [
                    BoxShadow(
                      offset: Offset(0, -5),
                      blurRadius: 3,
                      color: Colors.grey.shade300,
                    )
                  ]
                : [],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            maxHeight: MediaQuery.of(context).size.height / 2.7,
            minHeight: 200,
            collapsed: FadeTransition(
              opacity: _page,
              child: Container(
                padding: EdgeInsets.fromLTRB(30, 35, 30, 20),
                height: 200,
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade300,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plant.name,
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      widget.plant.category,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.plant.pricing.toString(),
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Opacity(
                            opacity: _inStock ? 0.0 : 1.0,
                            child: Text(
                              'Out of Stock!',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            )),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            StreamBuilder<int>(
                                stream: _countController.stream,
                                builder: (context, snapshot) {
                                  _count = snapshot.data ?? 0;
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    height: 35,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(35)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _countController
                                                .add(snapshot.data! - 1);
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                shape: BoxShape.circle),
                                            child: Text(
                                              '-',
                                              style: TextStyle(
                                                  fontSize: 26,
                                                  color: snapshot.data == 0
                                                      ? Colors.white54
                                                      : Colors.white),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle),
                                          child: Text(
                                            snapshot.data.toString(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _countController
                                                .add(snapshot.data! + 1);
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                shape: BoxShape.circle),
                                            child: Text(
                                              '+',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: snapshot.data != 2
                                                      ? Colors.white
                                                      : Colors.white54),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              onPressed: !_press.isAnimating
                                  ? () async {
                                      _press.forward();
                                      if (_count != 0)
                                        await database.addCart(UserCartAction(
                                            id: widget.plant.id,
                                            amount: _count));
                                      else {
                                        await database.removeCart(
                                            UserCartAction(
                                                id: widget.plant.id));
                                      }
                                      _press.reverse();
                                    }
                                  : () {},
                              child: Text(
                                'Cart',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size.fromHeight(40),
                                primary: _color.value,
                              ),
                            ),
                          ],
                        ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            panelBuilder: (scrollController) {
              return FadeTransition(
                  opacity: _page,
                  child: _slidingPanel(
                      context, scrollController, _panelController));
            },
            onPanelOpened: () => _description.forward(),
            onPanelClosed: () => _description.reverse(),
            color: !_entry.isCompleted ? Color(0xffebe9ec) : Colors.white,
          );
        },
      ),
    ));
  }

  Widget _slidingPanel(BuildContext context, ScrollController scrollController,
      PanelController panelController) {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 35, 30, 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.plant.name,
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            widget.plant.category,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(
            height: 30,
          ),
          FadeTransition(
              opacity: _opacity,
              child: Text(
                widget.plant.description,
                style: TextStyle(fontSize: 16),
              ))
        ],
      ),
    );
  }
}
