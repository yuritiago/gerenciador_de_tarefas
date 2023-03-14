import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/task_model.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Get.offNamed('/login');
  }

  void addTaskToHomePage(Task task) {
    _firestore.collection('tasks').add(task.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                Text(
                  'Olá, ${widget.user.displayName ?? widget.user.email}!',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Suas tarefas:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('tasks')
                      .where('user_id', isEqualTo: widget.user.uid)
                      .orderBy('date_time', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot task = snapshot.data!.docs[index];
                          return Card(
                            child: ListTile(
                              title: Text(task['title']),
                              subtitle:
                                  Text(task['date_time'].toDate().toString()),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _firestore
                                      .collection('tasks')
                                      .doc(task.id)
                                      .delete();
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Get.offNamed('/create-task');
        },
      ),
    );
  }
}
