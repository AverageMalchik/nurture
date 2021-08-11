import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({required this.uid});

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference plantsCollection =
      FirebaseFirestore.instance.collection('plants');
  //to check if displayName already exists
  Future checkDisplayName(String check) async {
    bool? _checker;
    await usersCollection
        .where('displayName', isEqualTo: check)
        .get()
        .then((qSnapshot) {
      _checker = qSnapshot.size == 0;
    }).onError((error, stackTrace) {
      _checker = false;
      print(error.toString());
    }).whenComplete(() => print('Check for displayName complete'));
    return _checker;
  }

  //to add verified displayName with uid
  Future<void> addDisplayName(UserNameReference userNameReference) async {
    await usersCollection
        .doc(uid)
        .set(userNameReference.toMap(), SetOptions(merge: true));
  }

  //read current username
  Stream<UserNameReference> userNameReferenceStream() {
    final snapshots = usersCollection.doc(uid).snapshots();
    return snapshots.map((snapshot) =>
        UserNameReference.fromMap(snapshot.data() as Map<String, dynamic>));
  }

  //to add photoURL to firestore with uid
  Future<void> addPhotoURL(UserPhotoReference userPhotoReference) async {
    await usersCollection
        .doc(uid)
        .set(userPhotoReference.toMap(), SetOptions(merge: true));
  }

  //read current photoURL
  Stream<UserPhotoReference> userPhotoReferenceStream() {
    final snapshots = usersCollection.doc(uid).snapshots();
    return snapshots.map((snapshot) =>
        UserPhotoReference.fromMap(snapshot.data() as Map<String, dynamic>));
  }

  //read plants database
  Stream<List<PlantReference>> plantReferenceStream() {
    final snapshots = plantsCollection.snapshots();
    return snapshots.map((snapshot) => convertSnapshot(snapshot));
  }

  //converting snapshot into list v.v.imp
  List<PlantReference> convertSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final map = doc.data() as Map<String, dynamic>;
      map['id'] = doc.id;
      return PlantReference.fromMap(map);
    }).toList();
  }
}
