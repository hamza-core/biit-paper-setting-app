import '../domain/handover_model.dart';

// Layer 3 (data). Lists for now, the API later.
class HandoverRepository {
  static HandoverModel? _active;

  static final List<HandoverModel> _history = [
    HandoverModel(
      facultyName: 'Dr. Naseer Ahmed',
      startDate: DateTime(2026, 6, 10),
      endDate: DateTime(2026, 6, 15),
      reason: '',
    ),
    HandoverModel(
      facultyName: 'Dr. Sadaf Gull',
      startDate: DateTime(2026, 1, 5),
      endDate: DateTime(2026, 1, 12),
      reason: '',
    ),
  ];

  final List<String> _faculty = [
    'Dr. Munir',
    'Dr. Saeed Iqbal',
    'Mr. Amir Rasheed',
    'Dr. Sadaf Gull',
    'Nauman Iqbal',
  ];

  Future<HandoverState> getState() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return HandoverState(active: _active, history: List.from(_history));
  }

  Future<List<String>> getFaculty() async {
    return _faculty;
  }

  Future<void> startHandover(HandoverModel handover) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _active = handover;
  }

  // Ends the active handover. It moves to the top of the history.
  Future<void> endHandover() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_active != null) {
      _history.insert(0, _active!);
      _active = null;
    }
  }
}
