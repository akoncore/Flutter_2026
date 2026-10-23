import 'package:flutter/material.dart';

enum Category {
  coding('Coding', Icons.code),
  languages('Languages', Icons.translate),
  science('Science', Icons.science_outlined),
  design('Design', Icons.palette_outlined),
  careers('Careers', Icons.work_outline);

  const Category(this.label, this.icon);
  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    coding => scheme.primary,
    languages => scheme.secondary,
    science => scheme.tertiary,
    design => scheme.onPrimaryContainer,
    careers => scheme.onSecondaryContainer,
  };
}

class Meeting {
  // The private const constructor only receives frozen lists from the factory.
  const Meeting._({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.place,
    required this.limit,
    required List<String> names,
    required this.online,
    required this.description,
    required this.favourite,
  }) : _names = names;

  factory Meeting({
    required String id,
    required String title,
    required Category category,
    required DateTime when,
    required String place,
    required int limit,
    List<String> names = const [],
    bool online = false,
    String? description,
    bool favourite = false,
  }) => Meeting._(
    id: id,
    title: title,
    category: category,
    when: when,
    place: place,
    limit: limit,
    names: List.unmodifiable(names),
    online: online,
    description: description,
    favourite: favourite,
  );

  factory Meeting.empty() => Meeting(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    title: '',
    category: Category.coding,
    when: DateTime.now().add(const Duration(days: 1)),
    place: '',
    limit: 12,
  );

  final String id;
  final String title;
  final Category category;
  final DateTime when;
  final String place;
  final int limit;
  final List<String> _names;
  final bool online;
  final String? description;
  final bool favourite;
  List<String> get names => _names;
  int get count => _names.length;
  int get free => limit - count;
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) =>
      name.trim().isNotEmpty && _names.any((entry) => entry == name.trim());
  ({int taken, int free}) get places => (taken: count, free: free);

  Meeting copyWith({
    String? title,
    Category? category,
    DateTime? when,
    String? place,
    int? limit,
    List<String>? names,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) => Meeting(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    when: when ?? this.when,
    place: place ?? this.place,
    limit: limit ?? this.limit,
    names: names ?? _names,
    online: online ?? this.online,
    description: clearDescription ? null : description ?? this.description,
    favourite: favourite ?? this.favourite,
  );
}
