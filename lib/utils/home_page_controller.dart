import 'package:get/get.dart';

import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '';

class HomePageController extends GetxController {
  final taskList = <Task>[].obs;
  final AuthService _authService = Get.find();
  final DatabaseService _databaseService = Get.put(DatabaseService(uid: ''));

  @override
  void onReady() {
    super.onReady();
    loadTaskList();
  }

  Future<void> loadTaskList() async {
    final uid = Get.find<AuthService>().user!.uid;
    final tasks = await Get.find<DatabaseService>().getTaskList(uid);
    taskList.assignAll(tasks);
  }

  void addTask(Task task) {
    taskList.add(task);
  }

  void deleteTask(Task task) async {
    try {
      await _databaseService.deleteTask(task.id as Task);
      taskList.remove(task);
    } catch (e) {
      Get.snackbar(
        'Erro ao deletar tarefa',
        'Ocorreu um erro ao deletar sua tarefa. Tente novamente mais tarde.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login'); // redirecionar para a tela de login
    } catch (e) {
      // lidar com qualquer erro que possa ocorrer ao fazer logout
      print(e);
    }
  }
}
