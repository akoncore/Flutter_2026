import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';
import 'students_screen.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.students,
      routes: {Routes.students: (_) => const StudentsScreen()},
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.student:
            final student = settings.arguments as Student;
            return MaterialPageRoute<Student>(
              builder: (_) => DetailScreen(student: student),
            );

          case Routes.edit:
            final student = settings.arguments as Student;
            return MaterialPageRoute<String>(
              builder: (_) => EditScreen(student: student),
            );

          default:
            return null;
        }
      },
    );
  }
}