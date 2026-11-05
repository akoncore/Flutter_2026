import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _expanded = true;
  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all books and quantities from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) context.read<Cart>().clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cart'),
      actions: [
        TextButton(
          onPressed: () => _confirmClear(context),
          child: const Text('Clear cart'),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) {
                if (cart.count == 0) {
                  return const Center(child: Text('Your cart is empty'));
                }
                return ListView(
                  children: [
                    for (final book in cart.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            book.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${book.price} ₸ ×${cart.qtyOf(book)} = ${book.price * cart.qtyOf(book)} ₸',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Increase ${book.title}',
                                onPressed: () => cart.increment(book),
                                icon: const Icon(Icons.add),
                              ),
                              IconButton(
                                tooltip: 'Remove ${book.title}',
                                onPressed: () => cart.remove(book),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Consumer<Cart>(
              child: const _TotalLabel(),
              builder: (context, cart, child) => Column(
                children: [
                  Row(
                    children: [
                      child!,
                      const Spacer(),
                      IconButton(
                        tooltip: _expanded ? 'Collapse total' : 'Expand total',
                        onPressed: () => setState(() => _expanded = !_expanded),
                        icon: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                        ),
                      ),
                    ],
                  ),
                  if (_expanded)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${cart.total} ₸',
                        key: const Key('cart-total'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TotalLabel extends StatelessWidget {
  const _TotalLabel();
  @override
  Widget build(BuildContext context) {
    debugPrint('total label build');
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.receipt_long_outlined),
        SizedBox(width: 8),
        Text('Total'),
      ],
    );
  }
}
