import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() => runApp(const StudentsApp());

class StudentsApp extends StatelessWidget {
  const StudentsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Students · Async lab',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF24665C)),
      scaffoldBackgroundColor: const Color(0xFFF6F8F7),
      useMaterial3: true,
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keep counters across route visits so the second Save can fail.
  final _manualApi = FakeApi();
  final _manualEmptyApi = FakeApi(empty: true);
  final _futureApi = FakeApi();
  final _futureEmptyApi = FakeApi(empty: true);
  bool _empty = false;

  Future<void> _open(Widget screen) async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Practice 10')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Text(
              'The data\narrives later.',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Students, Futures and streams. Explore what happens while the app waits.',
            ),
            const SizedBox(height: 32),
            _entry(
              'By hand',
              'Loading · error · empty · data',
              Icons.people_outline,
              () => _open(
                StudentsScreen(api: _empty ? _manualEmptyApi : _manualApi),
              ),
            ),
            _entry(
              'FutureBuilder',
              'One Future, many rebuilds',
              Icons.sync,
              () => _open(
                StudentsFutureScreen(
                  api: _empty ? _futureEmptyApi : _futureApi,
                ),
              ),
            ),
            _entry(
              'Countdown',
              'Two ways to manage a stream',
              Icons.timer_outlined,
              () => _open(const CountdownScreen()),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Empty dataset'),
              subtitle: const Text('Use an API with no students'),
              value: _empty,
              onChanged: (value) => setState(() => _empty = value),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _entry(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    ),
  );
}
