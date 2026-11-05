import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});
  @override
  Widget build(BuildContext context) {
    final n = context.select<Cart, int>((c) => c.count);
    debugPrint('badge build');
    return IconButton(
      tooltip: 'Open cart',
      onPressed: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        Navigator.of(context).pushNamed('/cart');
      },
      icon: Badge(
        label: Text('$n'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}

// The total changes when quantity changes; subscribe separately from the badge.
class CartTotalPreview extends StatelessWidget {
  const CartTotalPreview({super.key});
  @override
  Widget build(BuildContext context) {
    final total = context.select<Cart, int>((c) => c.total);
    return Center(child: Text('$total ₸'));
  }
}
