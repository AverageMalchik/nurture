import 'package:flutter/material.dart';
import 'package:nurture/UI/ui.dart';
import 'package:nurture/models/cart_list.dart';
import 'package:nurture/models/drawer_model.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  Map<String, dynamic> map = {};

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xffebeaef),
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 5,
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: 700,
                maxWidth: 400,
              ),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: database.cartList(),
                builder: (context, snapshot) {
                  print('started future builder');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    map = snapshot.data ?? {};
                    print('before plant ref stream builder');
                    return StreamBuilder<List<PlantReference>>(
                        initialData: <PlantReference>[],
                        stream: database.plantReferenceStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.active ||
                              snapshot.connectionState == ConnectionState.done)
                            return ListCart(
                              plants: snapshot.data!,
                              cartMap: map,
                            );
                          else
                            return SizedBox();
                        });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
