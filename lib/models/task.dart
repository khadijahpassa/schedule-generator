/*
File yang berada dalam folder model,
biasa disebut dengan Data Class

Biasanya Data Class dipresentasikan dengan bundling, dengan meng-import 
library Parcelize = Android Native. Kalo Multi Platform, udah ada Parcelize
 */
class Task {
  final String name;
  final int duration;
  final DateTime deadline;

  Task({required this.name, required this.duration, required this.deadline});

  // override = untuk membuat suatu turunan dari objek 
  // salah satu contohnya = Memungkinkan adanya function dalam function
  @override
  String toString() {
    return "Task{name: $name, duration: $duration, deadline: $deadline}";
  }
}

