import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/task_model.dart';

class DatabaseService extends ChangeNotifier {
  final String uid;
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  DatabaseService({required this.uid});

  Future<List<Task>> getTaskList() async {
    final snapshot = await _tasksCollection
        .where('userId', isEqualTo: uid)
        .orderBy('dateTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
            Task.fromFirestore(doc as QuerySnapshot<Map<String, dynamic>>))
        .expand((task) => task)
        .toList();
  }

  Future<void> createTask(Task task, File? imageUrl, String userId) async {
    task = task.copyWith(userId: userId);
    await _tasksCollection.add(task.toJson());
  }

  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(Task task) async {
    await _tasksCollection.doc(task.id).delete();
  }
}
