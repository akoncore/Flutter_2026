import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

class Probe extends StatelessWidget {
  const Probe({super.key, required this.mode, required this.onBuild});
  final String mode;
  final VoidCallback onBuild;
  @override
  Widget build(BuildContext context) {
    final count = switch (mode) {
      'watch' => context.watch<Cart>().count,
      'select' => context.select<Cart, int>((c) => c.count),
      _ => context.read<Cart>().count, // Deliberately incorrect demonstration.
    };
    onBuild();
    return Text('$count');
  }
}

void main() {
  for (final mode in ['watch', 'select', 'read']) {
    testWidgets('$mode measurement after three quantity increments', (
      tester,
    ) async {
      final cart = Cart()..add(books[0]);
      addTearDown(cart.dispose);
      var builds = 0;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: cart,
          child: MaterialApp(
            home: Probe(mode: mode, onBuild: () => builds++),
          ),
        ),
      );
      builds = 0;
      for (var i = 0; i < 3; i++) {
        cart.increment(books[0]);
        await tester.pump();
      }
      expect(builds, mode == 'watch' ? 3 : 0);
      cart.remove(books[0]);
      await tester.pump();
      expect(
        builds,
        mode == 'watch'
            ? 4
            : mode == 'select'
            ? 1
            : 0,
      );
      expect(find.text(mode == 'read' ? '1' : '0'), findsOneWidget);
    });
  }
  testWidgets('watch in callback reports provider assertion', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Cart(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  context.watch<Cart>().add(books[0]), // Deliberately wrong.
              child: const Text('Bad add'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Bad add'));
    final error = tester.takeException();
    expect(error, isAssertionError);
    expect(
      error.toString(),
      contains('Tried to listen to a value exposed with provider'),
    );
  });
}
