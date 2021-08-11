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
