import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.school_outlined, size: 64),
        const SizedBox(height: 24),
        Text('No students yet', style: Theme.of(context).textTheme.titleLarge),
      ],
    ),
  );
}
