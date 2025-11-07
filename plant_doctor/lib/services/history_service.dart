import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryService {
  static const String _historyKey = 'analysis_history';

  static Future<void> saveAnalysis(Map<String, dynamic> analysis) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_historyKey) ?? [];

    analysis['timestamp'] = DateTime.now().toIso8601String();
    history.add(json.encode(analysis));

    await prefs.setStringList(_historyKey, history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_historyKey) ?? [];

    return history
        .map((item) => json.decode(item) as Map<String, dynamic>)
        .toList();
  }
}
