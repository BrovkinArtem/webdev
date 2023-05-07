import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static Future<void> saveUser(String name, email, uid) async {
    final userCountSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    final userCount = userCountSnapshot.docs.length;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'email': email, 'name': name, 'portfolio_id': userCount + 1});
  }
}