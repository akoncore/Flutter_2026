import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key, required this.api});
  final FakeApi api;
  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  late final FakeApi _api = widget.api;
  // Not final: only an explicit retry/reload replaces this Future.
  late Future<List<Student>> _future;
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  void _retry() {
    setState(() {
      _future = _api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('FutureBuilder'),
      actions: [
        const Text('Dense'),
        Switch(
          value: _compact,
          onChanged: (value) => setState(() => _compact = value),
        ),
      ],
    ),
    body: FutureBuilder<List<Student>>(
      // Reset the snapshot on retry so a previous error is not retained
      // during the new loading state. Density toggles preserve this key.
      key: ObjectKey(_future),
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorView(onRetry: _retry);
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        final list = snapshot.data ?? const <Student>[];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload students'),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyView()
                  : StudentList(list, compact: _compact),
            ),
          ],
        );
      },
    ),
  );
}
