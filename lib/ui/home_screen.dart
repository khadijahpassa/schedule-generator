import 'package:flutter/material.dart';
import 'package:schedule_generator/models/task.dart';
import 'package:schedule_generator/services/gemini_service.dart';
import 'package:schedule_generator/ui/home_components/generate_button.dart';
import 'package:schedule_generator/ui/home_components/task_input.dart';
import 'package:schedule_generator/ui/home_components/task_list.dart';
import 'package:schedule_generator/ui/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  final GeminiService geminiService = GeminiService();
  bool isLoading = false;
  String? generatedResult;

  // code handling untuk action penambahan atau penginputan task
  void addTask(Task task) {
    setState(() => tasks.add(task));
  }
  // code handling untuk action penghapusan task yang sudah diinput
  void removeTask(int index) {
    setState(() => tasks.removeAt(index));
  }

  // ketika schedule di generate, maka menampilkan loading indicator
  // code handling untuk melakukan generate berdasarkan input user
  Future<void> generateSchedule() async {
    setState(() => isLoading = true);
    try {
      final result = await geminiService.generateSchedule(tasks);
      generatedResult = result;
      // mounted = bool. ketika di screen ada action yang valid dari user(handle problem ghost touch)
      if (context.mounted) _showSuccessDialog();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to Generate $e")));
      }
    }
    setState(() => isLoading = false);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Congrats!"),
            content: Text("Schedule generated successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResultScreen(result: generatedResult ?? "There is no result. Please try to generate another tasks")),
                  );
                },
                child: Text("View Result"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionColor = Colors.blueGrey[100];
    final sectionTitleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule Generator"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Task Input", style: sectionTitleStyle),
                  SizedBox(height: 12),
                  TaskInputSection(onTaskAdded: addTask)
                ],
              ),
            ),

            SizedBox(height: 20),
            Divider(),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sectionColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Task List", style: sectionTitleStyle),
                    SizedBox(height: 12),
                    Expanded(
                      child: TaskList(
                        tasks: tasks, 
                        onRemove: removeTask
                      ),
                    )
                  ],
                ),
              )
            ),

            SizedBox(height: 20),

            GenerateButton(
              isLoading: isLoading, 
              onPressed: generateSchedule
            )
          ],
        ),
      ),
    );
  }
}
