import 'dart:async';
import 'package:flutter/material.dart';
import '../models/countdown.dart';
import '../models/meeting.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});
  final DetailArguments args;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Meeting _item;
  late final Timer _timer;
  DateTime _now = DateTime.now();
  @override
  void initState() {
    super.initState();
    _item = widget.args.item;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _update(Meeting changed) {
    widget.args.onChanged(changed);
    setState(() => _item = changed);
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed<Meeting>(
      context,
      Routes.form,
      arguments: FormArguments(item: _item),
    );
    if (!mounted) return;
    if (result == null) return;
    _update(result);
  }

  Future<void> _delete() async {
    final accepted = await confirm(
      context,
      title: 'Delete session?',
      message: 'Delete “${_item.title}”?',
      action: 'Delete',
    );
    if (!mounted) return;
    if (accepted != true) return;
    widget.args.onDeleted(_item.id);
    Navigator.pop(context);
  }

  Future<void> _join() async {
    final name = widget.args.profile.name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Save your name in Profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              if (!mounted) return;
              widget.args.onTab(2);
              Navigator.pop(context);
            },
          ),
        ),
      );
      return;
    }
    if (_item.contains(name)) {
      _update(
        _item.copyWith(
          names: _item.names.where((entry) => entry != name).toList(),
        ),
      );
      return;
    }
    final accepted = await confirm(
      context,
      title: 'Join session?',
      message: 'Register $name for “${_item.title}”?',
      action: 'Join',
    );
    if (!mounted) return;
    if (accepted != true) return;
    _update(_item.copyWith(names: [..._item.names, name]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (:taken, :free) = _item.places;
    final joined = _item.contains(widget.args.profile.name);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _edit();
                } else {
                  _delete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 152,
                    child: Image.asset(
                      'assets/study_header.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: ColoredBox(
                      color: theme.colorScheme.surface.withValues(alpha: 0.68),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Icon(
                      _item.category.icon,
                      size: 48,
                      color: _item.category.color(theme.colorScheme),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: Chip(label: Text(_item.category.label)),
                  ),
                  Positioned(
                    right: 16,
                    top: 12,
                    child: Chip(
                      label: Text(
                        countdownLabel(Countdown.at(_item.when, _now)),
                      ),
                    ),
                  ),
                ],
              ),
              TabBar(
                tabs: [
                  const Tab(text: 'About'),
                  Tab(text: 'Participants ($taken)'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(_item.title, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 20),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Date and time'),
                          subtitle: Text(formatDateTime(_item.when)),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _item.online ? 'Meeting link' : 'Location',
                          ),
                          subtitle: SelectableText(_item.place),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Places'),
                          subtitle: Text(
                            '$taken taken · $free free · ${_item.limit} total',
                          ),
                        ),
                        if (_item.description case final description?) ...[
                          const SizedBox(height: 16),
                          Text(description),
                        ],
                      ],
                    ),
                    _item.names.isEmpty
                        ? const EmptyState(
                            icon: Icons.people_outline,
                            message:
                                'Nobody on the list yet. Be the first to join.',
                          )
                        : ListView(
                            children: [
                              for (final name in _item.names)
                                ListTile(
                                  title: Text(name),
                                  trailing: name == widget.args.profile.name
                                      ? const Chip(label: Text('You'))
                                      : null,
                                  selected: name == widget.args.profile.name,
                                ),
                            ],
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: !joined && _item.isFull ? null : _join,
                    child: Text(
                      joined
                          ? 'Leave session'
                          : _item.isFull
                          ? 'Session full'
                          : 'Join session',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
