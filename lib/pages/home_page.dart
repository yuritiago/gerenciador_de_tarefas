import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import '../utils/home_page_controller.dart';

class HomePage extends StatelessWidget {
  final User user;

  HomePage({Key? key, required this.user}) : super(key: key);
  final DatabaseService _databaseService = Get.put(DatabaseService(uid: ''));
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomePageController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final controller = Get.find<HomePageController>();
              controller.logout();
            },
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
                  'Olá, ${user.displayName ?? user.email}!',
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
                Obx(() {
                  final List<Task> taskList = controller.taskList;
                  if (taskList.isEmpty) {
                    return const Center(
                      child: Text('Você não tem tarefas.'),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: taskList.length,
                      itemBuilder: (context, index) {
                        final task = taskList[index];
                        return Card(
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Text(
                              '${task.dueDate} ${task.dueTime}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _databaseService.deleteTask(task);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
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
