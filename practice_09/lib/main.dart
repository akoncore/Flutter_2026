import 'package:flutter/material.dart';

import 'books_screen.dart';
import 'cart_screen.dart';

void main() => runApp(const Shell());

class Book {
  const Book({required this.title, required this.author, required this.price});
  final String title;
  final String author;
  final int price;
}

const books = [
  Book(
    title: 'Widgets All the Way Down',
    author: 'A. Nurmagambetova',
    price: 4200,
  ),
  Book(title: 'Null Safety for Humans', author: 'B. Seitkali', price: 3100),
  Book(
    title: 'Constraints Go Down, Sizes Go Up',
    author: 'C. Tashimova',
    price: 5600,
  ),
  Book(title: 'The Navigator Is a Stack', author: 'D. Alibekov', price: 2900),
  Book(
    title: 'Forms That Validate Themselves',
    author: 'E. Omarova',
    price: 3800,
  ),
  Book(
    title: 'Put It High, Subscribe Low',
    author: 'F. Kairatuly',
    price: 4700,
  ),
];

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final List<Book> _cart = [];
  int _revision = 0;
  void _add(Book b) => setState(() {
    _cart.add(b);
    _revision++;
  });
  void _remove(Book b) => setState(() {
    _cart.remove(b);
    _revision++;
  });
  @override
  Widget build(BuildContext context) => _Revision(
    revision: _revision,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      routes: {
        '/': (context) {
          _Revision.depend(context);
          return BooksScreen(
            cart: _cart,
            onAdd: _add,
            total: _cart.fold(0, (sum, b) => sum + b.price),
          );
        },
        '/cart': (context) {
          _Revision.depend(context);
          return CartScreen(items: _cart, onRemove: _remove);
        },
      },
    ),
  );
}

// MaterialApp routes are cached. This invalidation signal refreshes existing
// routes; all cart data and callbacks still travel through constructors.
class _Revision extends InheritedWidget {
  const _Revision({required this.revision, required super.child});
  final int revision;
  static void depend(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<_Revision>();
  }

  @override
  bool updateShouldNotify(_Revision oldWidget) =>
      revision != oldWidget.revision;
}
