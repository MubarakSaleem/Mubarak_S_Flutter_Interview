import 'package:flutter/material.dart';
import 'todo_repository.dart';

/// To-do list screen.
///
/// Approach:
/// - All read/write-to-disk logic is delegated to `TodoRepository`; this
///   widget only holds the in-memory `List<TodoItem>` and calls
///   `_persist()` after every mutation (add / toggle / delete) so state
///   on disk never drifts from what's on screen.
/// - `Dismissible` handles the swipe-to-delete gesture; a `Key` per item
///   (its stable `id`, not list index) is required so Flutter can track
///   which item is being swiped correctly even as the list reorders.
/// - Completed tasks get a strikethrough via `TextDecoration.lineThrough`.
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _repository = TodoRepository();
  final _textController = TextEditingController();

  List<TodoItem> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final saved = await _repository.loadTodos();
    if (!mounted) return;
    setState(() {
      _todos = saved;
      _isLoading = false;
    });
  }

  Future<void> _persist() => _repository.saveTodos(_todos);

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.add(
        TodoItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: text,
        ),
      );
    });
    _textController.clear();
    _persist();
  }

  void _toggleDone(TodoItem item) {
    setState(() => item.isDone = !item.isDone);
    _persist();
  }

  void _deleteTodo(TodoItem item) {
    setState(() => _todos.removeWhere((t) => t.id == item.id));
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Add a task…',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTodo(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addTodo,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _todos.isEmpty
                      ? const Center(child: Text('No tasks yet — add one above.'))
                      : ListView.builder(
                          itemCount: _todos.length,
                          itemBuilder: (context, index) {
                            final item = _todos[index];
                            return Dismissible(
                              // Stable id-based key, not index, so swipe
                              // tracking survives list mutations.
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Theme.of(context).colorScheme.errorContainer,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                              onDismissed: (_) => _deleteTodo(item),
                              child: CheckboxListTile(
                                value: item.isDone,
                                onChanged: (_) => _toggleDone(item),
                                title: Text(
                                  item.title,
                                  style: item.isDone
                                      ? const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
