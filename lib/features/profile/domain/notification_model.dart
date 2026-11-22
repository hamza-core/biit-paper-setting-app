class NotificationModel {
  final String title;
  final List<String> lines;
  final String time; // "New", "Oct 23", "2h ago"
  final bool isToday;
  final bool isUnread;

  NotificationModel({
    required this.title,
    required this.lines,
    required this.time,
    required this.isToday,
    required this.isUnread,
  });
}
