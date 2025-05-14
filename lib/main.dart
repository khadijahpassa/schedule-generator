import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:schedule_generator/ui/home_screen.dart';

Future<void> main() async{
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null); //harus dipanggil sebelum yang lain-lain dari intl dipanggil
  runApp(ScheduleGeneratorApp());
}

class ScheduleGeneratorApp extends StatelessWidget {
  const ScheduleGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Schedule Generator App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, //ikut patokan design google untuk material layout/design ✅
      ),
      home: HomeScreen(),
    );
  }
}