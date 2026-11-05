import 'package:flutter/material.dart';

import 'main.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items, required this.onRemove});
  final List<Book> items;
  final void Function(Book) onRemove;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cart')),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            children: items
                .map(
                  (b) => ListTile(
                    title: Text(b.title),
                    subtitle: Text('${b.price} ₸'),
                    trailing: IconButton(
                      tooltip: 'Remove ${b.title}',
                      onPressed: () => onRemove(b),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Total: ${items.fold<int>(0, (sum, b) => sum + b.price)} ₸',
          ),
        ),
      ],
    ),
  );
}
