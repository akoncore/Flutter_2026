import 'package:flutter/material.dart';

import 'students.dart';
import 'routes.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final List<Student> _students = List.of(students);

  Future<void> _open(int index) async {
    // The detail screen pops with the (possibly renamed) Student.
    final updated = await Navigator.of(context)
        .pushNamed<Student>(Routes.student, arguments: _students[index]);

    if (updated == null || !mounted) return;

    setState(() => _students[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final s = _students[index];

          return ListTile(
            leading: CircleAvatar(child: Text(s.name[0])),
            title: Text(s.name),
            subtitle: Text(s.group),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(index),
          );
        },
      ),
    );
  }
}