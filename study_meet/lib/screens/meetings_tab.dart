import 'package:flutter/material.dart';
import '../models/meeting.dart';
import '../widgets/empty_state.dart';
import '../widgets/meeting_card.dart';

class MeetingsTab extends StatefulWidget {
  const MeetingsTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
    this.favouritesOnly = false,
  });
  final List<Meeting> items;
  final ValueChanged<Meeting> onOpen;
  final ValueChanged<Meeting> onFavourite;
  final VoidCallback onBrowse;
  final bool favouritesOnly;
  @override
  State<MeetingsTab> createState() => _MeetingsTabState();
}

class _MeetingsTabState extends State<MeetingsTab> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Category? _category;
  bool _showPast = false;
  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clear() {
    _search.clear();
    setState(() {
      _category = null;
      _showPast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final source = widget.items
        .where((item) => !widget.favouritesOnly || item.favourite)
        .toList();
    final visible =
        source
            .where(
              (item) =>
                  (_category == null || item.category == _category) &&
                  (_showPast || !item.isPast) &&
                  item.title.toLowerCase().contains(query),
            )
            .toList()
          ..sort((a, b) {
            if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
            return a.when.compareTo(b.when);
          });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextFormField(
            controller: _search,
            focusNode: _searchFocus,
            validator: (_) => null,
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            onTapOutside: (_) => _searchFocus.unfocus(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Search study sessions',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final category in Category.values)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(category.icon, size: 18),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Include past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
              const SizedBox(width: 12),
              Text(
                '${visible.length} sessions',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: source.isEmpty && widget.favouritesOnly
              ? EmptyState(
                  icon: Icons.favorite_border,
                  message: 'No favourites yet. Save a session you like.',
                  action: 'Browse sessions',
                  onAction: widget.onBrowse,
                )
              : visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No sessions match your filters.',
                  action: 'Reset filters',
                  onAction: _clear,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    Widget card(int index) => MeetingCard(
                      item: visible[index],
                      onTap: () => widget.onOpen(visible[index]),
                      onFavourite: () => widget.onFavourite(visible[index]),
                    );
                    if (constraints.maxWidth >= 600) {
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ((constraints.maxWidth - 32) / 360)
                              .ceil(),
                          mainAxisExtent: 190,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (_, index) => card(index),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: visible.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 4),
                      itemBuilder: (_, index) => card(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
