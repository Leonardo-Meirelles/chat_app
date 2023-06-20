import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final firebase = FirebaseStorage.instance;

class FirebaseStorageService {
  static Future<String> storeImage({
    required UserCredential userCredentials,
    required File file,
  }) async {
    try {
      final storageRef = firebase
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

      await storageRef.putFile(file);

      final imageURL = await storageRef.getDownloadURL();

      return imageURL;
    } catch (e) {
      rethrow;
    }
  }
}
