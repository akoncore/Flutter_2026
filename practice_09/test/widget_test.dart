import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('add search quantity remove and clear across routes', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
    );
    await tester.tap(find.byKey(ValueKey('add-${books[0].title}')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('add-${books[1].title}')));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search')), 'NULL');
    await tester.pumpAndSettle();
    expect(find.text(books[0].title), findsNothing);
    expect(find.text(books[1].title), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search')), 'not a book');
    await tester.pumpAndSettle();
    expect(find.text('No books found'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase ${books[0].title}'));
    await tester.pumpAndSettle();
    expect(find.text('11500 ₸'), findsOneWidget);
    expect(find.text('4200 ₸ ×2 = 8400 ₸'), findsOneWidget);
    await tester.tap(find.byTooltip('Collapse total'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cart-total')), findsNothing);
    await tester.tap(find.byTooltip('Expand total'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove ${books[0].title}'));
    await tester.pumpAndSettle();
    expect(find.text('3100 ₸'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.byKey(ValueKey('add-${books[0].title}')), findsOneWidget);
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text(books[1].title), findsOneWidget);
    await tester.tap(find.text('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('0 ₸'), findsOneWidget);
  });
  testWidgets('production subscriptions ignore quantity changes', (
    tester,
  ) async {
    final messages = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    try {
      await tester.pumpWidget(
        ChangeNotifierProvider(create: (_) => Cart(), child: const Shell()),
      );
      messages.clear();
      await tester.tap(find.byKey(ValueKey('add-${books[0].title}')));
      await tester.pumpAndSettle();
      expect(messages.where((m) => m.startsWith('row ')).length, 1);
      expect(messages.where((m) => m == 'BooksScreen build').length, 0);
      await tester.tap(find.byTooltip('Open cart'));
      await tester.pumpAndSettle();
      messages.clear();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byTooltip('Increase ${books[0].title}'));
        await tester.pumpAndSettle();
      }
      expect(messages.where((m) => m == 'badge build').length, 0);
      expect(messages.where((m) => m.startsWith('row ')).length, 0);
      expect(messages.where((m) => m == 'total label build').length, 0);
      await tester.tap(find.byTooltip('Remove ${books[0].title}'));
      await tester.pumpAndSettle();
      expect(messages.where((m) => m == 'badge build').length, 1);
    } finally {
      debugPrint = original;
    }
  });
}
