import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService extends ChangeNotifier {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file) async {
    final storageRef = _storage.ref();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final fileRef = storageRef.child(fileName);

    final uploadTask = fileRef.putFile(file);

    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> deleteFile(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      final storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    }
  }

  Future<String> uploadTaskImage(File imageFile) async {
    final storageRef = _storage.ref();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final fileRef = storageRef.child(fileName);

    final uploadTask = fileRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }
}
