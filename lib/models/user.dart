// import 'package:cloud_firestore/cloud_firestore.dart';

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
