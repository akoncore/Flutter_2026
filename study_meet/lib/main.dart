import 'package:flutter/material.dart';
import 'models/meeting.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeMode.system;
  ThemeData _theme(Brightness brightness) {
    // A framework colorScheme role supplies the seed, without literal colors.
    final seed = ThemeData().colorScheme.primary;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }

  Route<dynamic> _notFound(RouteSettings settings) => MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'StudyMeet',
    debugShowCheckedModeBanner: false,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _mode,
    routes: {
      Routes.home: (_) =>
          Shell(mode: _mode, onTheme: (value) => setState(() => _mode = value)),
    },
    onGenerateRoute: (settings) => switch ((
      settings.name,
      settings.arguments,
    )) {
      (Routes.detail, final DetailArguments args) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => DetailScreen(args: args),
      ),
      (Routes.form, final FormArguments args) => MaterialPageRoute<Meeting>(
        settings: settings,
        builder: (_) => FormScreen(item: args.item),
      ),
      _ => null,
    },
    onUnknownRoute: _notFound,
  );
}
