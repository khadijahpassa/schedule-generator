import 'package:flutter/material.dart';
import 'package:schedule_generator/models/task.dart';

// IMPORTANT: untuk mendefinisikan sebuah variable yang bersifat public ataupun private,
// wajib untuk dideskripsikan di dalam blok kode 

// bersifat public
class TaskInputSection extends StatefulWidget {
  final void Function(Task) onTaskAdded;
  const TaskInputSection({super.key, required this.onTaskAdded});

  @override
  State<TaskInputSection> createState() => _TaskInputSectionState();
}
// bersifat private
class _TaskInputSectionState extends State<TaskInputSection> {
  final taskController = TextEditingController();
  final durationController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void _addTask() {
    // perkondisian apabila seluruh/beberapa input area masih kosong
    if (taskController.text.isEmpty || 
        durationController.text.isEmpty ||
        selectedDate == null ||
        // keyword return: mengembalikan hasil, yang penting ada salah satu kondisi yang true dan 
        //akan return hasilnya. karena semua input gak mandatory
        selectedTime == null) return; 

    final deadline = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedDate!.hour,
      selectedDate!.minute,
    );

    widget.onTaskAdded(Task(
      name: taskController.text,
      // duration itu campuran int dan String, jadi pake tryParse. 0 sebagai default duration
      duration: int.tryParse(durationController.text) ?? 0,
      deadline: deadline
    ));

    // statement ini akan dijalankan ketika satu buah task lengkap sudah berhasil dibuat 
    // dan dimasukkan ke dalam container list tasks
    taskController.clear();
    durationController.clear();
    setState(() {
      selectedDate = null;
      selectedTime = null;
    });
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030)
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Task',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Duration (minutes)'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate, 
                    child: Text(selectedDate == null ?
                      "Pick Date" : 
                      "${selectedDate!.toLocal()}".split(' ')[0] // (' ') masukin ini karana ada beberapa informasi yang dicantumin
                    )
                  )
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime, 
                    child: Text(selectedTime == null ?
                      "Pick Time" : 
                      "${selectedTime!.format(context)}".split(' ')[0]
                    )
                  )
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTask, 
              child: Text('Add Task')
            )
          ],
        ),
      ),
    );
  }
}