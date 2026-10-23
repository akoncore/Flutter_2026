import 'package:flutter/material.dart';
import '../models/meeting.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.items,
    required this.mode,
    required this.onProfile,
    required this.onTheme,
  });
  final Profile profile;
  final List<Meeting> items;
  final ThemeMode mode;
  final ValueChanged<Profile> onProfile;
  final ValueChanged<ThemeMode> onTheme;
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;
  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();
  static final _groupPattern = RegExp(r'^[A-Za-z]{2,8}-\d{2,4}$');
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _name.text = widget.profile.name;
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    widget.onProfile(
      Profile(name: _name.text.trim(), group: _group.text.trim()),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final joined = widget.items.fold<int>(
      0,
      (sum, item) => sum + (item.contains(widget.profile.name) ? 1 : 0),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.school_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Your study profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('You are on $joined lists'),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              focusNode: _nameFocus,
              decoration: const InputDecoration(
                labelText: 'Name',
                helperText: 'Use a unique name, then press Next or Save.',
              ),
              validator: (value) =>
                  (value?.trim().isEmpty ?? true) ? 'Enter your name' : null,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) => _nameFocus.unfocus(),
              onFieldSubmitted: (_) {
                _save();
                _groupFocus.requestFocus();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _group,
              focusNode: _groupFocus,
              decoration: const InputDecoration(
                labelText: 'Group',
                helperText: 'Optional, for example CS-2301',
              ),
              validator: (value) =>
                  value == null ||
                      value.trim().isEmpty ||
                      _groupPattern.hasMatch(value.trim())
                  ? null
                  : 'Use letters-digits, for example CS-2301',
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => _groupFocus.unfocus(),
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save profile'),
            ),
            const SizedBox(height: 32),
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final mode in ThemeMode.values)
                  ChoiceChip(
                    label: Text(switch (mode) {
                      ThemeMode.system => 'System',
                      ThemeMode.light => 'Light',
                      ThemeMode.dark => 'Dark',
                    }),
                    selected: widget.mode == mode,
                    onSelected: (_) => widget.onTheme(mode),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Sessions and profile are kept in memory. Restarting the app restores the examples.',
            ),
          ],
        ),
      ),
    );
  }
}
