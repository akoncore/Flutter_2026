import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});
  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen build');
    final query = _query.trim().toLowerCase();
    final visible = books
        .where((b) => '${b.title} ${b.author}'.toLowerCase().contains(query))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartTotalPreview(), CartBadge(), SizedBox(width: 12)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              key: const Key('search'),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search books or authors',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
      body: visible.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Text(
                    'THE FLUTTER SHELF',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                for (final book in visible)
                  BookRow(key: ValueKey(book.title), book: book),
              ],
            ),
    );
  }
}

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});
  final Book book;
  @override
  Widget build(BuildContext context) {
    final added = context.select<Cart, bool>(
      (cart) => cart.items.contains(book),
    );
    debugPrint('row ${book.title}');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${book.author}\n${book.price} ₸'),
        isThreeLine: true,
        trailing: added
            ? const Text('Added', style: TextStyle(fontWeight: FontWeight.w600))
            : OutlinedButton(
                key: ValueKey('add-${book.title}'),
                onPressed: () {
                  final ok = context.read<Cart>().add(book);
                  if (ok) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Added')));
                  }
                },
                child: const Text('Add'),
              ),
      ),
    );
  }
}
