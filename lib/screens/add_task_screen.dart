import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.taskToEdit != null ? widget.taskToEdit!.title : '',
    );
    _descriptionController = TextEditingController(
      text: widget.taskToEdit != null ? widget.taskToEdit!.description : '',
    );
    _selectedDate =
        widget.taskToEdit != null ? widget.taskToEdit!.date : DateTime.now();

    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      _selectedDate = widget.taskToEdit!.date;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.taskToEdit != null ? 'Editar Tarefa' : 'Adicionar Tarefa',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Data:'),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final task = Task(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      date: _selectedDate,
                      isCompleted: false,
                    );

                    if (widget.taskToEdit != null) {
                      task.id = widget.taskToEdit!.id;
                      await Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).updateTask(task);
                    } else {
                      await Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).addTask(task);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.taskToEdit == null
                              ? 'Tarefa adicionada com sucesso!'
                              : 'Tarefa atualizada com sucesso!',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },
                child: Text(
                  widget.taskToEdit != null
                      ? 'Atualizar Tarefa'
                      : 'Adicionar Tarefa',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
