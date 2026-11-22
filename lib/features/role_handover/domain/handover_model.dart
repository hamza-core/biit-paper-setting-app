class HandoverModel {
  final String facultyName;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  HandoverModel({
    required this.facultyName,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });
}

// What the Role Handover screen needs: the active one (if any) and the history.
class HandoverState {
  final HandoverModel? active;
  final List<HandoverModel> history;

  HandoverState({required this.active, required this.history});
}
