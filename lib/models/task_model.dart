import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  String id;
  String userId;
  String title;
  String description;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  bool isImportant;
  List<String> attachments;
  DateTime? dateTime;
  bool? important;
  File? imageUrl;

  Task({
    required this.title,
    required this.description,
    required this.isImportant,
    required this.attachments,
    required this.userId,
    required this.id,
    this.dueDate,
    this.dueTime,
    this.dateTime,
    this.important,
    required this.imageUrl,
  });

  static Task fromJson(Map<String, dynamic> json) {
    final data = json['dueDate'] as Timestamp?;
    final dueDate = data?.toDate();
    final dueTime = TimeOfDay(
      hour: json['dueTimeHour'] as int,
      minute: json['dueTimeMinute'] as int,
    );
    final dateTime = json['dateTime'] == null
        ? null
        : (json['dateTime'] as Timestamp).toDate();
    final important = json['important'] as bool?;

    return Task(
      title: json['title'] as String,
      description: json['description'] as String,
      isImportant: json['isImportant'] as bool,
      attachments: List<String>.from(json['attachments'] as List<dynamic>),
      userId: json['userId'] as String,
      id: json['id'] as String,
      dueDate: dueDate,
      dueTime: dueTime,
      dateTime: dateTime,
      important: important,
      imageUrl: json['imageUrl'] as File,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
        'dueTimeHour': dueTime?.hour,
        'dueTimeMinute': dueTime?.minute,
        'isImportant': isImportant,
        'attachments': attachments,
        'dateTime': dateTime == null ? null : Timestamp.fromDate(dateTime!),
        'important': important,
        'userId': userId,
        'id': id,
        'imageUrl': imageUrl,
      };

  static List<Task> fromFirestore(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    final tasks = <Task>[];
    for (final doc in snapshot.docs) {
      final task = Task.fromJson(doc.data());
      task.id = doc.id;
      tasks.add(task);
    }
    return tasks;
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool? isImportant,
    List<String>? attachments,
    DateTime? dateTime,
    bool? important,
    String? imageUrl,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isImportant: isImportant ?? this.isImportant,
      attachments: attachments ?? List.from(this.attachments),
      dateTime: dateTime ?? this.dateTime,
      important: important ?? this.important,
      imageUrl: imageUrl == null ? null : File(imageUrl),
    );
  }
}
