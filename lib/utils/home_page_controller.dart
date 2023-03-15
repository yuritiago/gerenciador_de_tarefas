import 'package:get/get.dart';

import '../models/task_model.dart';
import '../services/database_service.dart';

class HomePageController extends GetxController {
  RxList<Task> tasks = <Task>[].obs;

  Future<void> loadTaskList() async {
    final databaseService = Get.find<DatabaseService>();
    final taskList = await databaseService.getTaskList();
    tasks.value = taskList;
  }

  void addTask(Task task) {
    tasks.add(task);
  }

  void deleteTask(Task task) {
    tasks.remove(task);
  }
}
