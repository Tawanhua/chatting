import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('users');

  // Save user data
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'groups': [],
      'profilePic': '',
      'uid': uid
    });
  }

  // Get user data
  Future gettingUserData(String email) async {
    QuerySnapshot<Object?> snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }
}
