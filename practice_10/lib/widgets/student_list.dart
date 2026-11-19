import 'package:flutter/material.dart';

import '../api/fake_api.dart';

class StudentList extends StatelessWidget {
  const StudentList(this.students, {super.key, this.compact = false});
  final List<Student> students;
  final bool compact;
  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 96),
    itemCount: students.length,
    itemBuilder: (context, index) {
      final student = students[index];
      return Card(
        child: ListTile(
          dense: compact,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(child: Text(student.name[0])),
          title: Text(student.name),
          subtitle: Text(student.group),
          trailing: Text('GPA ${student.gpa?.toStringAsFixed(1) ?? '—'}'),
        ),
      );
    },
  );
}
