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
  final PlantLite plantLite;
  UserPlaceOrder({required this.plantLite});
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (plantLite.plant.water == "Light")
      map['water'] = DateTime.now().add(Duration(minutes: 60)).toString();
    else
      map['water'] = DateTime.now().add(Duration(minutes: 30)).toString();
    map['last'] = DateTime.now().toString();
    map['count'] = plantLite.count;
    return map;
  }
}

class UserMyPlants {
  final int count;
  final String last;
  final String water;
  UserMyPlants({required this.count, required this.last, required this.water});
  Map<String, dynamic> toMap() {
    return {
      'count': count,
      'last': last,
      'water': water,
    };
  }
}
