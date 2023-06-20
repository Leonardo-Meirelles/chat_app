import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firestore = FirebaseFirestore.instance;

class FirebaseFirestoreService {
  static Future<void> storeUserData({
    required String userName,
    required UserCredential userCredentials,
    required String imageUrl,
  }) async {
    try {
      await firestore.collection('users').doc(userCredentials.user!.uid).set({
        'user_name': userName,
        'email': userCredentials.user!.email,
        'image_url': imageUrl,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> storeMessage({
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    try {
      final userData = await firestore.collection('users').doc(user.uid).get();

      firestore.collection('chat').add({
        'text': message,
        'created_at': Timestamp.now(),
        'user_id': user.uid,
        'user_name': userData.data()!['user_name'],
        'user_image': userData.data()!['image_url'],
      });
    } catch (e) {
      rethrow;
    }
  }
}
