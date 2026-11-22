import '../data/handover_repository.dart';
import 'handover_model.dart';

// Layer 2 (domain). Rules for role handover.
class HandoverService {
  final HandoverRepository _repository = HandoverRepository();

  Future<HandoverState> getState() {
    return _repository.getState();
  }

  Future<List<String>> getFaculty() {
    return _repository.getFaculty();
  }

  // Returns an error text, or null when the form is fine.
  String? validate(String? faculty, DateTime? start, DateTime? end) {
    if (faculty == null) return 'Please select a faculty member';
    if (start == null || end == null) {
      return 'Please select the start and end date';
    }
    if (end.isBefore(start)) return 'End date cannot be before the start date';
    return null;
  }

  Future<void> startHandover({
    required String? faculty,
    required DateTime? start,
    required DateTime? end,
    required String reason,
  }) {
    String? error = validate(faculty, start, end);
    if (error != null) throw error;
    return _repository.startHandover(
      HandoverModel(
        facultyName: faculty!,
        startDate: start!,
        endDate: end!,
        reason: reason.trim(),
      ),
    );
  }

  Future<void> endHandover() {
    return _repository.endHandover();
  }

  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _two(int number) {
    return number < 10 ? '0$number' : '$number';
  }

  // "Oct 15, 2026"
  String dateText(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // "Jun 10 - Jun 15, 2026"
  String rangeText(DateTime start, DateTime end) {
    String from = '${_months[start.month - 1]} ${_two(start.day)}';
    String to = '${_months[end.month - 1]} ${_two(end.day)}, ${end.year}';
    return '$from - $to';
  }
}
