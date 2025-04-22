import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../screens/add_task_screen.dart'; // Ensure this path is correct

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma tarefa encontrada',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (ctx, index) {
        final task = tasks[index];
        return Dismissible(
          key: ValueKey(task.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Confirmar'),
                    content: const Text(
                      'Deseja realmente excluir esta tarefa?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (direction) {
            taskProvider.deleteTask(task.id!);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                task.title + " - " + DateFormat('dd/MM/yyyy').format(task.date),
                style: TextStyle(
                  decoration:
                      task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                ),
              ),
              subtitle: Text(task.description),
              trailing: Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  taskProvider.toggleTaskCompletion(task);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(taskToEdit: task),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
