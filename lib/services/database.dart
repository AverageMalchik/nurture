import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:nurture/models/plant.dart';
import 'package:nurture/models/user.dart';
import 'package:nurture/services/authentication.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference plantsCollection =
      FirebaseFirestore.instance.collection('plants');
  final auth = FirebaseAuth.instance;

  //set profile for Anonymous User
  Future<void> setAnonymousProfile() async {
    try {
      await addDisplayName(UserNameReference('Guest'));
      await addPhotoURL(UserPhotoReference(
          'https://media.tarkett-image.com/large/TH_24567080_24594080_24596080_24601080_24563080_24565080_24588080_001.jpg'));
    } catch (err) {
      print(err.toString());
    }
  }

  //transfer anonymous data
  Future<void> transferData(BuildContext context) async {
    final favoritesSnapshot = await usersCollection
        .doc(uid)
        .collection('actions')
        .doc('favorites')
        .get();
    final cartSnapshot =
        await usersCollection.doc(uid).collection('actions').doc('cart').get();
    await usersCollection.doc(uid).delete();
    await auth.currentUser!.delete();
    await AuthenticationService().signInGoogle();
    print('current: ${auth.currentUser!.uid}');
    await usersCollection
        .doc(auth.currentUser!.uid)
        .collection('actions')
        .doc('favorites')
        .set(favoritesSnapshot.data() ?? {}, SetOptions(merge: true));
    await usersCollection
        .doc(auth.currentUser!.uid)
        .collection('actions')
        .doc('cart')
        .set(cartSnapshot.data() ?? {}, SetOptions(merge: true));
  }

  // Future<void> setTransferData(
  //     Map<String, dynamic> favourites, Map<String, dynamic> cart) async {
  //   print('google uid: $uid');
  //   await usersCollection
  //       .doc(uid)
  //       .collection('actions')
  //       .doc('favorites')
  //       .set(favourites, SetOptions(merge: true));
  //   await usersCollection
  //       .doc(uid)
  //       .collection('actions')
  //       .doc('cart')
  //       .set(cart, SetOptions(merge: true));
  // }

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

  //clear cart
  Future<void> clearCart() async {
    await usersCollection.doc(uid).collection('actions').doc('cart').set({});
  }

  //get snapshot of user's cart
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCount() {
    final snapshot =
        usersCollection.doc(uid).collection('actions').doc('cart').snapshots();
    return snapshot;
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

  //place order and remove from stock too
  Future<void> placeOrder(List<PlantLite> list) async {
    list.forEach((plantLite) async {
      await plantsCollection
          .doc(plantLite.plant.id)
          .update({'stock': FieldValue.increment(-plantLite.count)});
      var now = DateTime.now().toString();
      await usersCollection
          .doc(uid)
          .collection('actions')
          .doc('myplants')
          .collection(plantLite.plant.id)
          .doc(now)
          .set(UserPlaceOrder(plantLite: plantLite).toMap(),
              SetOptions(merge: true));
    });
  }

  //update subcollections and documents in myplants
  Future<void> changeMyPlants(
      String collectionId, String documentId, UserMyPlants userMyPlants) async {
    print('changeMyPlants');
    await usersCollection
        .doc(uid)
        .collection('actions')
        .doc('myplants')
        .collection(collectionId)
        .doc(documentId)
        .set(userMyPlants.toMap());
  }

  //retrieve my_plants map from firebase
  Future<List<MyPlantreference>> getMyPlants(
      List<PlantReference> plants) async {
    List<MyPlantreference> list = [];
    for (int i = 0; i < plants.length; i++) {
      final snapshots = await usersCollection
          .doc(uid)
          .collection('actions')
          .doc('myplants')
          .collection(plants[i].id)
          .get();
      list.addAll(convertMyPlantList(snapshots, plants[i]));
    }
    return list;
  }

  List<MyPlantreference> convertMyPlantList(
      QuerySnapshot snapshot, PlantReference plant) {
    if (snapshot.size != 0) {
      return snapshot.docs.map((doc) {
        final map = doc.data() as Map<String, dynamic>;
        map['purchase'] = doc.id;
        map['plant'] = plant;
        return MyPlantreference.fromMap(map);
      }).toList();
    } else {
      return [];
    }
  }
}
