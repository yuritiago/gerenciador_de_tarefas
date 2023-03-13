import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/services/database_service.dart';
import 'package:todo_list/services/storage_service.dart';

import '../services/auth_service.dart';
import '../utils/debouncing_controller.dart';
import 'home_page.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  CreateTaskPageState createState() => CreateTaskPageState();
}

class CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = DebouncingController(
    delay: const Duration(milliseconds: 500),
  );
  final _descriptionController = TextEditingController();

  String _title = '';
  String _description = '';
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  File? _image;
  bool _isImportant = false;

  bool _isLoading = false;
  bool _taskCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Tarefa'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Título',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Insira o título da tarefa',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O título não pode estar vazio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                  ),
                  maxLines: null,
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Data de vencimento: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: _showDatePicker,
                      child: const Text('Escolher'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Horário de vencimento: ${_dueTime.hour}:${_dueTime.minute}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: _showTimePicker,
                      child: const Text('Escolher'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _getImageFromCamera,
                      child: const Text('Câmera'),
                    ),
                    ElevatedButton(
                      onPressed: _getImageFromGallery,
                      child: const Text('Galeria'),
                    ),
                    _image == null
                        ? const SizedBox.shrink()
                        : SizedBox(
                            height: 50.0,
                            child: Image.file(_image!),
                          ),
                  ],
                ),
                const SizedBox(height: 16.0),
                CheckboxListTile(
                  title: const Text('Importante'),
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value ?? false;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _createTask,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.save),
                      SizedBox(width: 8.0),
                      Text('Salvar'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final BuildContext context = this.context;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _showTimePicker() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );

    if (pickedTime != null && pickedTime != _dueTime) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _createTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final state = context.findAncestorStateOfType<HomePageState>();
      final uid =
          Provider.of<AuthService>(context, listen: false).currentUser!.uid;
      final databaseService =
          Provider.of<DatabaseService>(context, listen: false);
      final task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        dueTime: _dueTime,
        isImportant: _isImportant,
        attachments: [],
        dateTime: DateTime.now(),
        important: false,
        id: '',
        userId: uid,
        imageUrl: null,
      );

      // Invoca a função de retorno de chamada passando a nova tarefa como parâmetro
      state?.addTaskToHomePage(task);

      try {
        final databaseService =
            Provider.of<DatabaseService>(context, listen: false);
        final storageService =
            Provider.of<StorageService>(context, listen: false);

        String imageUrl = '';
        if (_image != null) {
          // Faz o upload da imagem e pega a URL gerada
          final storageService =
              Provider.of<StorageService>(context, listen: false);
          final ref = await storageService.uploadTaskImage(_image!);
          imageUrl = ref;
        }

        await databaseService.createTask(task, _image, uid);
      } catch (e) {
        print('Erro ao criar tarefa: $e');
      } finally {
        setState(() {
          _isLoading = false;
          _taskCreated = true;
        });
      }
    }
  }
}
