import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop/main.dart';

void main() {
  testWidgets('lifted routes share the cart and rebuild six rows', (
    tester,
  ) async {
    final messages = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = original);
    await tester.pumpWidget(const Shell());
    messages.clear();
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    expect(messages.where((s) => s == 'BooksScreen build').length, 1);
    expect(messages.where((s) => s.startsWith('row ')).length, 6);
    await tester.tap(find.text('Add').first);
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Open cart'));
    await tester.pumpAndSettle();
    expect(find.text('Total: 7300 ₸'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove Widgets All the Way Down'));
    await tester.pumpAndSettle();
    expect(find.text('Total: 3100 ₸'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Added'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    debugPrint = original;
  });
}

