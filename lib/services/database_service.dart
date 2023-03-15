import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';

class DatabaseService extends ChangeNotifier {
  final String uid;
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  DatabaseService({required this.uid});

  Future<List<Task>> getTaskList(String uid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: uid)
        .get();
    final taskList = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Task(
        id: doc.id,
        title: data['title'],
        description: data['description'],
        dueDate: data['dueDate'] != null
            ? (data['dueDate'] as Timestamp).toDate()
            : null,
        dueTime: data['dueTime'] != null
            ? TimeOfDay.fromDateTime(data['dueTime']!)
            : null,
        isImportant: data['isImportant'],
        attachments: List<String>.from(data['attachments'] ?? []),
        userId: data['userId'],
        imageUrl: data['imageUrl'],
      );
    }).toList();
    return taskList;
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
