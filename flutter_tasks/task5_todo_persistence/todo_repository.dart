import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A single to-do item. Kept as a plain, Flutter-free data class so it can
/// be reused by both the repository (persistence) and the UI without
/// either side depending on the other's concerns.
class TodoItem {
  final String id;
  String title;
  bool isDone;

  TodoItem({required this.id, required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        isDone: json['isDone'] as bool? ?? false,
      );
}

/// All persistence logic lives here, isolated from any widget.
///
/// Storage approach: the whole list is encoded as one JSON string under a
/// single `shared_preferences` key. This keeps read/write atomic (no
/// partial-list corruption) and simple — appropriate for a to-do list of
/// modest size. For much larger datasets a real database (sqflite/Isar)
/// would be a better fit, but that's beyond what this task calls for.
class TodoRepository {
  static const _storageKey = 'todo_items';

  Future<List<TodoItem>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted/unexpected data shouldn't crash the app — start fresh.
      return [];
    }
  }

  Future<void> saveTodos(List<TodoItem> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
