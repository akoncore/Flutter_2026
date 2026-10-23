import 'package:flutter/material.dart';
import '../data/seed.dart';
import '../models/meeting.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/confirm.dart';
import 'meetings_tab.dart';
import 'profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, required this.mode, required this.onTheme});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onTheme;
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Meeting> _items = seedMeetings();
  Profile _profile = const Profile.empty();
  int _tab = 0;
  void _select(int index) => setState(() => _tab = index);
  void _replace(Meeting changed) => setState(
    () => _items = [
      for (final item in _items)
        if (item.id == changed.id) changed else item,
    ],
  );
  void _delete(String id) =>
      setState(() => _items = _items.where((item) => item.id != id).toList());
  void _saveProfile(Profile profile) {
    final oldName = _profile.name;
    // A name is the lab's identity. Rename memberships atomically with profile.
    final updated = oldName.isEmpty || oldName == profile.name
        ? _items
        : _items
              .map(
                (item) => item.copyWith(
                  names: {
                    for (final name in item.names)
                      if (name == oldName) profile.name else name,
                  }.toList(),
                ),
              )
              .toList();
    setState(() {
      _profile = profile;
      _items = updated;
    });
  }

  Future<void> _create() async {
    final result = await Navigator.pushNamed<Meeting>(
      context,
      Routes.form,
      arguments: const FormArguments(),
    );
    if (!mounted) return;
    if (result == null) return;
    setState(() => _items = [..._items, result]);
  }

  void _open(Meeting item) => Navigator.pushNamed<void>(
    context,
    Routes.detail,
    arguments: DetailArguments(
      item: item,
      profile: _profile,
      onChanged: _replace,
      onDeleted: _delete,
      onTab: _select,
    ),
  );
  Future<void> _reset() async {
    final accepted = await confirm(
      context,
      title: 'Reset data?',
      message: 'Restore the 12 example sessions and clear your profile?',
      action: 'Reset',
    );
    if (!mounted) return;
    if (accepted != true) return;
    final seed = seedMeetings();
    setState(() {
      _items = seed;
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(switch (_tab) {
        0 => 'StudyMeet',
        1 => 'Favourites',
        _ => 'Profile',
      }),
    ),
    drawer: Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: ListTile(
                title: Text('StudyMeet'),
                subtitle: Text('Learn together on campus'),
              ),
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('About StudyMeet'),
                    content: const Text(
                      'Student study sessions. Mobile Development Lab 1. Data is stored only in memory.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Reset data'),
              onTap: () {
                Navigator.pop(context);
                _reset();
              },
            ),
          ],
        ),
      ),
    ),
    body: SafeArea(
      child: IndexedStack(
        index: _tab,
        children: [
          MeetingsTab(
            items: _items,
            onOpen: _open,
            onFavourite: (item) =>
                _replace(item.copyWith(favourite: !item.favourite)),
            onBrowse: () => _select(0),
          ),
          MeetingsTab(
            items: _items,
            onOpen: _open,
            onFavourite: (item) =>
                _replace(item.copyWith(favourite: !item.favourite)),
            onBrowse: () => _select(0),
            favouritesOnly: true,
          ),
          ProfileTab(
            profile: _profile,
            items: _items,
            mode: widget.mode,
            onProfile: _saveProfile,
            onTheme: widget.onTheme,
          ),
        ],
      ),
    ),
    floatingActionButton: _tab == 2
        ? null
        : FloatingActionButton.extended(
            onPressed: _create,
            icon: const Icon(Icons.add),
            label: const Text('New session'),
          ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: _select,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favourites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}
