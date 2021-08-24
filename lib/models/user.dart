// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nurture/models/plant.dart';

class UserNameReference {
  final String displayName;
  UserNameReference(this.displayName);

  //get custom userNameReference
  factory UserNameReference.fromMap(Map<String, dynamic> data) {
    final String displayName = data['displayName'];
    return UserNameReference(displayName);
  }
  Map<String, dynamic> toMap() {
    return {'displayName': displayName};
  }
}

class UserPhotoReference {
  final String photoURL;
  UserPhotoReference(this.photoURL);

  factory UserPhotoReference.fromMap(Map<String, dynamic> data) {
    final String photoURL = data['photoURL'];
    return UserPhotoReference(photoURL);
  }

  Map<String, dynamic> toMap() {
    return {'photoURL': photoURL};
  }
}

class UserCartAction {
  final String id;
  final int? amount;
  UserCartAction({required this.id, this.amount});

  Map<String, dynamic> toMap() {
    return {'$id': amount};
  }

  String delete() {
    return id;
  }
}

class UserFavoriteAction {
  final String id;
  UserFavoriteAction({required this.id});

  Map<String, bool> toMap() {
    return {'$id': true};
  }

  String delete() {
    return id;
  }
}

class UserPlaceOrder {
  final List<PlantLite> list;
  UserPlaceOrder({required this.list});
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    list.forEach((plantLite) {
      if (plantLite.plant.water == "Light")
        map['${plantLite.plant.id}'] = DateTime.now().add(Duration(hours: 6));
      else
        map['${plantLite.plant.id}'] = DateTime.now().add(Duration(hours: 12));
      map['${plantLite.plant.id}count'] = plantLite.count;
    });
    return map;
  }
}
