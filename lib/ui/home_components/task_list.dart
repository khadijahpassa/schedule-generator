import 'package:flutter/material.dart';
import 'package:schedule_generator/models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(int) onRemove;

  const TaskList({super.key, required this.tasks, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      // (_, i) --> syntax singkat untuk mendefinisikan sebuah perkondisian
      // apabila indexnya tidak kosong(ada isi) >> return Card nya
      itemBuilder: (_, i) => Card(
        child: ListTile(
          title: Text(tasks[i].name),
          subtitle: Text(
            "The duration is ${tasks[i].duration} min and the deadline is on ${tasks[i].deadline.toLocal()}"
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => onRemove(i)
            ),
        ),
      ),
    );
  }
}