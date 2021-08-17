import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

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
    return snapshots.map((snapshot) => convertPlantList(snapshot));
  }

  //converting available plants query snapshot into list
  List<PlantReference> convertPlantList(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final map = doc.data() as Map<String, dynamic>;
      map['id'] = doc.id;
      return PlantReference.fromMap(map);
    }).toList();
  }

  //converting available plants query snapshot into list without Stream

  //add to user's cart
  Future<void> addCart(UserCartAction userCartAction) async {
    await usersCollection
        .doc(uid)
        .collection('actions')
        .doc('cart')
        .set(userCartAction.toMap(), SetOptions(merge: true));
  }

  //remove from cart
  Future<void> removeCart(UserCartAction userCartAction) async {
    await usersCollection
        .doc(uid)
        .collection('actions')
        .doc('cart')
        .update({'${userCartAction.delete()}': FieldValue.delete()});
  }

  //get snapshot of user's cart
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCount() {
    final snapshot =
        usersCollection.doc(uid).collection('actions').doc('cart').snapshots();
    return snapshot;
  }

  Future<Map<String, dynamic>?> cartList() async {
    final snapshot =
        await usersCollection.doc(uid).collection('actions').doc('cart').get();
    return snapshot.data();
  }

  //add to favourites
  Future<void> addFavorites(UserFavoriteAction userFavoriteAction) async {
    await usersCollection
        .doc(uid)
        .collection('actions')
        .doc('favorites')
        .set(userFavoriteAction.toMap(), SetOptions(merge: true));
  }

  //remove from favorites
  Future<void> removeFavorites(UserFavoriteAction userFavoriteAction) async {
    await usersCollection
        .doc(uid)
        .collection('actions')
        .doc('favorites')
        .update({'${userFavoriteAction.delete()}': FieldValue.delete()});
  }

  //read favorites
  Stream<DocumentSnapshot<Map<String, dynamic>>> getFavorites() {
    final snapshot = usersCollection
        .doc(uid)
        .collection('actions')
        .doc('favorites')
        .snapshots();
    return snapshot;
  }
}
