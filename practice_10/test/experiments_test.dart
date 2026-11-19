// Deliberately broken variants are isolated here, never in lib/.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:students_async/api/fake_api.dart';
import 'package:students_async/api/countdown.dart';

final capturedErrors = <Object>[];

class BrokenProbe extends StatefulWidget {
  const BrokenProbe({super.key, this.stream = false});
  final bool stream;
  @override
  State<BrokenProbe> createState() => _BrokenProbeState();
}

class _BrokenProbeState extends State<BrokenProbe> {
  void brokenUpdate() {
    try {
      setState(() {});
    } catch (error) {
      capturedErrors.add(error);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.stream) {
      // Intentionally no cancel: reproduce the lab's leak.
      countdown(10).listen((i) => brokenUpdate());
    } else {
      unawaited(Future<void>.delayed(const Duration(seconds: 2), brokenUpdate));
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  testWidgets('event order: synchronous work, frame, delayed events', (
    tester,
  ) async {
    final order = <String>[];
    order.add('A');
    unawaited(
      Future<void>.delayed(const Duration(seconds: 2), () => order.add('B')),
    );
    order.add('C');
    unawaited(
      FakeApi().fetchStudents().then((l) => order.add('${l.length} students')),
    );
    await tester.pumpWidget(
      Builder(
        builder: (_) {
          order.add('first frame');
          return const SizedBox();
        },
      ),
    );
    expect(order, ['A', 'C', 'first frame']);
    await tester.pump(const Duration(seconds: 2));
    expect(order, ['A', 'C', 'first frame', 'B', '6 students']);
    debugPrint('ACTUAL ORDER: ${order.join(', ')}');
  });

  test('sleep blocks the event loop', () async {
    var eventRan = false;
    final pending = Future<void>(() {
      eventRan = true;
    });
    final watch = Stopwatch()..start();
    sleep(const Duration(seconds: 2));
    expect(eventRan, isFalse);
    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(1900));
    await pending;
    expect(eventRan, isTrue);
    debugPrint(
      'BLOCKED: ${watch.elapsedMilliseconds} ms before queued event ran',
    );
  });

  testWidgets('missing mounted guard reproduces disposed State error', (
    tester,
  ) async {
    await tester.pumpWidget(const BrokenProbe());
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    final error = capturedErrors.removeAt(0);
    expect(error.toString(), contains('setState() called after dispose()'));
    debugPrint('CAPTURED: ${error.toString().split('\n').first}');
  });

  testWidgets('missing cancel continues tick 6 through 0 after leaving at 7', (
    tester,
  ) async {
    await tester.pumpWidget(const BrokenProbe(stream: true));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpWidget(const SizedBox());
    for (var i = 6; i >= 0; i--) {
      await tester.pump(const Duration(seconds: 1));
      final error = capturedErrors.removeAt(0);
      expect(error.toString(), contains('setState() called after dispose()'));
      if (i == 6) debugPrint('CAPTURED: ${error.toString().split('\n').first}');
    }
  });

  test('unawaited failures reach the zone after apparent success', () async {
    final api = FakeApi();
    final errors = <Object>[];
    final done = Completer<void>();
    var apparentSuccess = false;
    unawaited(
      runZonedGuarded<Future<void>>(
        () async {
          await api.save(6);
          // The intentionally wrong Save callback: pop immediately.
          unawaited(api.save(6));
          apparentSuccess = true;
        },
        (error, stack) {
          errors.add(error);
          done.complete();
        },
      ),
    );
    await done.future;
    expect(apparentSuccess, isTrue);
    expect(errors.single.toString(), 'Bad state: server rejected 6');
    debugPrint('Unhandled Exception: ${errors.single} (captured by test zone)');
    final failedFetch = Completer<void>();
    unawaited(
      runZonedGuarded<Future<void>>(
        () async {
          for (var i = 0; i < 3; i++) {
            await api.fetchStudents();
          }
        },
        (error, stack) {
          expect(error, isA<NoConnectionException>());
          debugPrint('Unhandled Exception: $error (captured by test zone)');
          failedFetch.complete();
        },
      ),
    );
    await failedFetch.future;
  });
}
