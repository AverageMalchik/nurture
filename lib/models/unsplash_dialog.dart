import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nurture/models/user.dart';
import 'dart:convert' as convert;

import 'package:nurture/services/database.dart';
import 'package:provider/provider.dart';

class UnsplashDialog extends StatefulWidget {
  @override
  _UnsplashDialogState createState() => _UnsplashDialogState();
}

class _UnsplashDialogState extends State<UnsplashDialog> {
  var _response;
  // to get random image from unsplash, each time
  Future getRandomImage() async {
    try {
      _response = await http.get(Uri.parse(
          'https://api.unsplash.com/photos/random/?query=nature&client_id=_bJpqffJzTK2KduhJk7sOh5MTmx_stxEOiuZyAOpRDI'));
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context, listen: false);
    return FutureBuilder(
      future: getRandomImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var jsonResponse =
              convert.jsonDecode(_response.body) as Map<String, dynamic>;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.greenAccent,
                  ),
                  CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        NetworkImage(jsonResponse['urls']['small']),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () async {
                      await database.addPhotoURL(
                          UserPhotoReference(jsonResponse['urls']['small']));
                    },
                    icon: Icon(Icons.check),
                  ),
                  IconButton(
                      onPressed: () => setState(() {}),
                      icon: Icon(Icons.swap_horiz_rounded))
                ],
              )
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
