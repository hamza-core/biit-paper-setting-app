// Remembers earlier states so a screen can offer undo and redo.
// T is the state, for example a copy of a list.
class ChangeHistory<T> {
  final List<T> _undo = [];
  final List<T> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  // Call this with the state BEFORE a change.
  void remember(T before) {
    _undo.add(before);
    _redo.clear();
  }

  // Returns the state to go back to (or null). `current` is kept for redo.
  T? undo(T current) {
    if (_undo.isEmpty) return null;
    _redo.add(current);
    return _undo.removeLast();
  }

  T? redo(T current) {
    if (_redo.isEmpty) return null;
    _undo.add(current);
    return _redo.removeLast();
  }
}
