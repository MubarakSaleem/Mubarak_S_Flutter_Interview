import 'package:flutter/material.dart';

/// State management choice: plain `setState`.
///
/// Why: the entire "state" here is a single count integer plus two small
/// stacks (undo/redo) that only this one screen cares about. There's no
/// need to share this state with any other widget in the tree, so pulling
/// in Provider (or any other package) would just be extra ceremony for a
/// screen this size. `setState` keeps everything local and easy to follow.
///
/// Design notes on the "state vs UI" separation the task asks about:
/// - All counter/history logic lives in `_CounterHistory`, a plain Dart
///   class with no Flutter imports. It knows nothing about widgets.
/// - `CounterScreen` only calls into `_CounterHistory` and calls
///   `setState` to repaint. This means the history/undo/redo logic could
///   be lifted out, unit-tested, or reused (e.g. in a different state
///   management solution) without touching any UI code.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

/// An action that was applied to the counter. Storing the delta (not just
/// "increment"/"decrement" as a label) makes undo/redo trivial: undo just
/// applies the inverse delta, redo re-applies the original delta.
class _CounterAction {
  final int delta; // +1 for increment, -1 for decrement
  final DateTime timestamp;

  _CounterAction(this.delta) : timestamp = DateTime.now();

  String get label => delta > 0 ? 'Incremented' : 'Decremented';
}

/// Pure logic class: current count + undo/redo stacks capped at 10.
/// Deliberately has zero Flutter/widget dependencies.
class _CounterHistory {
  static const int maxHistory = 10;

  int _count = 0;
  final List<_CounterAction> _undoStack = [];
  final List<_CounterAction> _redoStack = [];

  int get count => _count;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// Last 3 actions, most recent first — used for the on-screen log.
  List<_CounterAction> get recentLog =>
      _undoStack.reversed.take(3).toList(growable: false);

  void _applyAction(_CounterAction action) {
    _count += action.delta;
    _undoStack.add(action);
    // Cap history at 10: drop the oldest entry once we exceed the limit.
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
  }

  void increment() {
    // A brand-new action invalidates any redo history (standard undo/redo
    // semantics: you can't redo something after taking a fresh action).
    _redoStack.clear();
    _applyAction(_CounterAction(1));
  }

  void decrement() {
    _redoStack.clear();
    _applyAction(_CounterAction(-1));
  }

  void undo() {
    if (!canUndo) return;
    final action = _undoStack.removeLast();
    _count -= action.delta; // reverse it
    _redoStack.add(action);
    if (_redoStack.length > maxHistory) {
      _redoStack.removeAt(0);
    }
  }

  void redo() {
    if (!canRedo) return;
    final action = _redoStack.removeLast();
    _count += action.delta; // re-apply it
    _undoStack.add(action);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
  }
}

class _CounterScreenState extends State<CounterScreen> {
  final _history = _CounterHistory();

  void _increment() => setState(_history.increment);
  void _decrement() => setState(_history.decrement);
  void _undo() => setState(_history.undo);
  void _redo() => setState(_history.redo);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Counter (Undo/Redo)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_history.count}',
              style: theme.textTheme.displayLarge,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonal(
                  onPressed: _decrement,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: _increment,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  // Disabled (onPressed: null) whenever there's nothing to
                  // undo — Flutter buttons auto-gray-out when null.
                  onPressed: _history.canUndo ? _undo : null,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _history.canRedo ? _redo : null,
                  icon: const Icon(Icons.redo),
                  label: const Text('Redo'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Last 3 actions', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              width: 260,
              child: _history.recentLog.isEmpty
                  ? Text(
                      'No actions yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Column(
                      children: [
                        for (final action in _history.recentLog)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '${action.label} (${action.delta > 0 ? '+1' : '-1'}) '
                              'at ${_formatTime(action.timestamp)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
