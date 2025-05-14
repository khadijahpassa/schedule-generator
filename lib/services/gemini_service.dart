import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:schedule_generator/models/task.dart';

class GeminiService {
  //Untuk gerbang komunikasi awal antara client dan server
  //client --> kode project/aplikasi yang telah dideploy
  //server --> Gemini API

  //static direpresentasikan dengan _ didepannya
  static const String _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  final String apiKey;

  /*
  Ini adalah sebuah ternary operator untuk memastikan
  apakah nilai dari API KEY tersedia
   */
  GeminiService() : apiKey = dotenv.env["GEMINI_API_KEY"] ?? "" {
    if (apiKey.isEmpty) {
      throw ArgumentError("Please input your API KEY");
    }
  }

  /* 
  Logika untuk generatng result dari input/prompt yang diberikan
  yang akan diotomasi oleh AI API
  */
  //Future dijalankan terlebih dahulu tapi action nya nanti kalo codenya sudah diexecute atau dicompile
  Future<String> generateSchedule(List<Task> tasks) async {
    _validateTasks(tasks);
    //variable yang digunakan untuk menampung prompt REQUEST yang akan dieksekusi oleh AI
    final prompt = _buildPrompt(tasks);

    //sebagai percobaan pengiriman request ke AI
    //apakah promptnya valid/bisa dieksekusi?
    try {
      print("Prompt: \n$prompt");

      //variable yang digunakan untuk menampung RESPONSE dari request ke API AI
      final response = await http.post(
        //ini adalah starting point untuk penggunaan endpoint dari API
        Uri.parse("$_baseUrl?key=$apiKey"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              //role = seorang yang memberikan instruksi kepada AI melalui prompt
              "role": "user",
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        })
      );

      return _handleResponse(response);
    } catch (e) {
      throw ArgumentError("Failed to generate schedule: $e");
    }
  }

  String _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    /*
    switch = perkondisian yang berisi statement general yang dapat dieksekusi 
    oleh berbagai macam action(multiple cases), tanpa harus bergantung pada single-statement 
    yang dimiliki oleh setiap action yang ada pada parametes "case"
     */
    switch (response.statusCode) {
      case 200:
        return data["candidates"][0]["content"]["parts"][0]["text"];
      case 404:
        throw ArgumentError("Server Not Found");
      case 500:
        throw ArgumentError("Internal Server Error");
      default:
        throw ArgumentError("Unknown Error: ${response.statusCode}");
    }
  }

  String _buildPrompt(List<Task> tasks){
    // berfungsi untuk menyetting format tanggal dan waktu lokal(Indonesian)
    initializeDateFormatting();
    final dateFormatter = DateFormat("dd mm yyyy 'pukul' hh:mm, 'id_ID'");

    final taskList = tasks.map((task) {
      final formatDeadline = dateFormatter.format(task.deadline);
      return "- ${task.name} (Duration: ${task.duration} minutes, Deadline: $formatDeadline)";
    });

    //menggunakan framework R-T-A (Roles-Task-Action) untuk prompting
    return '''
    Saya adalah seorang siswa, dan saya memiliki daftar sebagai berikut:

    $taskList

    Tolong susun jadwal yang optimal dan efisien berdasarkan daftar tugas tersebut. 
    Tolong tentukan prioritasnya berdasarkan *deadline yang paling dekat* dan *durasi tugas*.
    Tolong buat jadwal yang sistematis dari pagi hari sampai malam hari.
    Tolong pastikan semua tugas dapat selesai semua sebelum deadline.

    Tolong buatkan jadwal dalam format list per jam, misalnya:
    - 07.00 - 08.00 : Melaksanakan piket kamar.
    ''';
  }


  void _validateTasks(List<Task> tasks) {
    // bentuk dari single statement dari if-else condition
    // karena cukup dengan action throw error
    if (tasks.isEmpty) throw ArgumentError("Please input your task before generating");
  }
 }