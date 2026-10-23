import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String message;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (action case final label?) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(label)),
          ],
        ],
      ),
    ),
  );
}
