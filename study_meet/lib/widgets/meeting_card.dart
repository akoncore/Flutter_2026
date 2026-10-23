import 'package:flutter/material.dart';
import '../models/meeting.dart';
import '../utils/format.dart';

class MeetingCard extends StatelessWidget {
  const MeetingCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavourite,
  });
  final Meeting item;
  final VoidCallback onTap;
  final VoidCallback onFavourite;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = item.category.color(theme.colorScheme);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 72,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      child: Icon(item.category.icon, color: color),
                    ),
                    if (item.free <= 5)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Text(
                              item.isFull ? 'FULL' : '${item.free} left',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatDateTime(item.when),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      item.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: item.favourite ? 'Remove favourite' : 'Add favourite',
                onPressed: onFavourite,
                icon: Icon(
                  item.favourite ? Icons.favorite : Icons.favorite_border,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
