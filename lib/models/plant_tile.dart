import 'package:flutter/material.dart';
import 'package:nurture/models/plant.dart';
import 'package:shimmer/shimmer.dart';

class PlantTile extends StatefulWidget {
  final PlantReference plant;
  PlantTile({required this.plant});

  @override
  _PlantTileState createState() => _PlantTileState();
}

class _PlantTileState extends State<PlantTile>
    with SingleTickerProviderStateMixin {
  // var _imageBorderRadius = BorderRadius.all(Radius.circular(10));
  // // ignore: avoid_init_to_null
  // var _border = null;
  late Image _coverImage;
  bool _loading = true;
  int _count = 0;
  late bool _inStock;
  ColorFilter _colorFilter =
      ColorFilter.mode(Colors.grey.shade900, BlendMode.saturation);

  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    //check if product is in stock
    _inStock = widget.plant.stock >= 1 ? true : false;
    //controller for border glow animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _coverImage = Image.network(
      widget.plant.cover,
      fit: BoxFit.contain,
    );
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          _controller.reverse();
          break;
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _coverImage.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void applyTint(int count) {
    if (count == 1 || count == 2) {
      _controller.forward();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_loading
        ? Container(
            height: 300,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: _inStock
                      ? _coverImage
                      : ColorFiltered(
                          colorFilter: _colorFilter,
                          child: _coverImage,
                        ),
                ),
                FadeTransition(
                  opacity: animation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.deepPurple.shade100, BlendMode.modulate),
                      child: _coverImage,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(widget.plant.name),
                    _inStock
                        ? Text(widget.plant.pricing.toString())
                        : Text('Unavailable'),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.favorite_rounded,
                    ),
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: 2,
                  left: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _inStock
                            ? (_count == 0
                                ? null
                                : () {
                                    setState(() {
                                      --_count;
                                    });
                                  })
                            : null,
                        icon: Icon(
                          Icons.remove_circle_rounded,
                        ),
                        iconSize: 24,
                        color: Colors.deepPurple,
                        disabledColor: Colors.deepPurple[300],
                        constraints: BoxConstraints(maxWidth: 20),
                        splashRadius: 1,
                      ),
                      IconButton(
                        onPressed: _inStock
                            ? (_count == 2
                                ? null
                                : () {
                                    applyTint(++_count);
                                  })
                            : null,
                        icon: Icon(
                          Icons.add_circle_rounded,
                        ),
                        color: Colors.deepPurple,
                        disabledColor: Colors.deepPurple[300],
                        iconSize: 24,
                        splashRadius: 1,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        : Shimmer.fromColors(
            child: Container(
              margin: EdgeInsets.all(10),
              height: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.black),
            ),
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade200);
  }
}
