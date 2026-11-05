import 'package:flutter_test/flutter_test.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

void main() {
  test('model invariants without widgets', () {
    final cart = Cart();
    addTearDown(cart.dispose);
    var notifications = 0;
    cart.addListener(() => notifications++);
    expect(cart.add(books[0]), isTrue);
    expect(cart.add(books[1]), isTrue);
    expect(cart.add(books[0]), isFalse);
    expect(notifications, 2);
    cart.remove(books[0]);
    expect('${cart.count} items, ${cart.total} ₸', '1 items, 3100 ₸');
    expect(() => cart.items.add(books[0]), throwsUnsupportedError);
    final snapshot = cart.items;
    cart.increment(books[1]);
    expect(cart.count, 1);
    expect(cart.qtyOf(books[1]), 2);
    expect(cart.total, 6200);
    expect(notifications, 4);
    cart.increment(books[0]);
    cart.remove(books[0]);
    expect(notifications, 4);
    cart.clear();
    expect(cart.items, isEmpty);
    expect(cart.total, 0);
    expect(cart.qtyOf(books[1]), 0);
    expect(snapshot, [books[1]]);
    expect(notifications, 5);
    cart.clear();
    expect(notifications, 5);
  });
}
