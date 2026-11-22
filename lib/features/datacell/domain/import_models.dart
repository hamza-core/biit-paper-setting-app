// One row of the imported excel file.
// type is: teacher, course, department or account.
class ImportRow {
  final String type;
  String id;
  String name;
  String detail;

  ImportRow({
    required this.type,
    required this.id,
    required this.name,
    required this.detail,
  });
}

// Numbers shown in the "Import Successful" dialog.
class ImportSummary {
  final int teachers;
  final int courses;
  final int departments;

  ImportSummary({
    required this.teachers,
    required this.courses,
    required this.departments,
  });
}
