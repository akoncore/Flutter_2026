import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/api/fake_api.dart';
import 'package:students_async/main.dart';
import 'package:students_async/students_screen.dart';
import 'package:students_async/students_future_screen.dart';
import 'package:students_async/countdown_screen.dart';

Future<void> finishLoad(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets(
    'API delays, concurrent request numbering, empty and save failures',
    (tester) async {
      final api = FakeApi();
      final results = <int>[];
      final errors = <Object>[];
      for (var i = 0; i < 3; i++) {
        unawaited(
          api.fetchStudents().then(
            (v) {
              results.add(v.length);
            },
            onError: (Object e) {
              errors.add(e);
            },
          ),
        );
      }
      await tester.pump(const Duration(seconds: 1));
      expect(results, isEmpty);
      await tester.pump(const Duration(seconds: 1));
      expect(results, [6, 6]);
      expect(errors.single, isA<NoConnectionException>());
      final empty = FakeApi(empty: true).fetchStudents();
      await tester.pump(const Duration(seconds: 2));
      expect(await empty, isEmpty);
      final saved = api.save(6);
      await tester.pump(const Duration(seconds: 1));
      await saved;
      final rejected = expectLater(api.save(6), throwsA(isA<StateError>()));
      await tester.pump(const Duration(seconds: 1));
      await rejected;
    },
  );

  testWidgets('manual loading, data, third error, retry and nullable GPA', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: StudentsScreen(api: FakeApi())));
    expect(find.text('Loading students…'), findsOneWidget);
    await finishLoad(tester);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('GPA —'), findsOneWidget);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Reload students'));
      await tester.pump();
      await finishLoad(tester);
    }
    expect(find.text('Could not load students'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Loading students…'), findsOneWidget);
    await finishLoad(tester);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
  });

  testWidgets('both screens display empty and handle disposal during fetch', (
    tester,
  ) async {
    for (final manual in [true, false]) {
      final api = FakeApi(empty: true);
      Widget screen() =>
          manual ? StudentsScreen(api: api) : StudentsFutureScreen(api: api);
      await tester.pumpWidget(MaterialApp(home: screen()));
      await finishLoad(tester);
      expect(find.text('No students yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(MaterialApp(home: screen()));
      await tester.pumpWidget(const SizedBox());
      await finishLoad(tester);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('ten density toggles keep one Future; error retry loads again', (
    tester,
  ) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: StudentsFutureScreen(api: api)));
    await finishLoad(tester);
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
    }
    expect(api.calls, 1);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Reload students'));
      await tester.pump();
      await finishLoad(tester);
    }
    expect(find.text('Could not load students'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Loading students…'), findsOneWidget);
    await finishLoad(tester);
    expect(api.calls, 4);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
  });

  testWidgets('save disables double taps, pops on success, stays on error', (
    tester,
  ) async {
    await tester.pumpWidget(const StudentsApp());
    await tester.tap(find.text('By hand'));
    await tester.pumpAndSettle();
    await finishLoad(tester);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Saving…'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Practice 10'), findsOneWidget);
    await tester.tap(find.text('By hand'));
    await tester.pumpAndSettle();
    await finishLoad(tester);
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('server rejected 6'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('leaving during save never uses a disposed context', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: StudentsScreen(api: FakeApi())));
    await finishLoad(tester);
    await tester.tap(find.text('Save'));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  for (final manual in [false, true]) {
    testWidgets(
      'countdown ${manual ? 'B' : 'A'} reaches zero and stops after disposal',
      (tester) async {
        Widget counter() =>
            manual ? const SubscriptionCountdown() : const BuilderCountdown();
        await tester.pumpWidget(MaterialApp(home: counter()));
        for (var i = 10; i >= 0; i--) {
          await tester.pump(const Duration(seconds: 1));
          expect(find.text('$i'), findsOneWidget);
        }
        expect(find.text('Finished'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(MaterialApp(home: counter()));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text('7'), findsOneWidget);
        final logs = <String>[];
        final old = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };
        try {
          await tester.pumpWidget(const SizedBox());
          for (var i = 0; i < 9; i++) {
            await tester.pump(const Duration(seconds: 1));
          }
          expect(logs, isEmpty);
          expect(tester.takeException(), isNull);
        } finally {
          debugPrint = old;
        }
      },
    );
  }
}
