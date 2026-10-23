import 'package:flutter/material.dart';
import '../models/meeting.dart';
import '../utils/format.dart';
import '../widgets/confirm.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.item});
  final Meeting? item;
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _form = GlobalKey<FormState>();
  late final Meeting _initial;
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _limit;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  DateTime? _date;
  TimeOfDay? _time;
  Category? _category;
  late bool _online;
  bool _saving = false;
  bool _leaving = false;
  bool _asking = false;
  late String _baseline;

  String get _snapshot => [
    _title.text,
    _place.text,
    _limit.text,
    _description.text,
    _date?.toIso8601String() ?? '',
    _time?.hour.toString() ?? '',
    _time?.minute.toString() ?? '',
    _category?.name ?? '',
    '$_online',
  ].map((value) => '${value.length}:$value').join();
  bool get _dirty => !_leaving && _snapshot != _baseline;
  DateTime? get _combined {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  void initState() {
    super.initState();
    _initial = widget.item ?? Meeting.empty();
    _title = TextEditingController(text: _initial.title);
    _place = TextEditingController(text: _initial.place);
    _limit = TextEditingController(text: '${_initial.limit}');
    _description = TextEditingController(text: _initial.description ?? '');
    _category = _initial.category;
    _online = _initial.online;
    if (widget.item != null) {
      _date = DateUtils.dateOnly(_initial.when);
      _time = TimeOfDay.fromDateTime(_initial.when);
    }
    _dateText = TextEditingController(
      text: _date == null ? '' : formatDate(_initial.when),
    );
    _timeText = TextEditingController(
      text: _time == null ? '' : formatTime(_initial.when),
    );
    _baseline = _snapshot;
    for (final controller in [_title, _place, _limit, _description]) {
      controller.addListener(_changed);
    }
  }

  void _changed() => setState(() {});
  @override
  void dispose() {
    for (final controller in [
      _title,
      _place,
      _limit,
      _description,
      _dateText,
      _timeText,
    ]) {
      controller.dispose();
    }
    for (final focus in [
      _titleFocus,
      _placeFocus,
      _limitFocus,
      _descriptionFocus,
      _dateFocus,
      _timeFocus,
    ]) {
      focus.dispose();
    }
    super.dispose();
  }

  String? _titleError(String? value) {
    final length = value?.trim().length ?? 0;
    return length < 3 || length > 60 ? 'Use 3–60 characters' : null;
  }

  String? _placeError(String? value) {
    final place = value?.trim() ?? '';
    if (place.isEmpty) {
      return _online ? 'Enter the meeting link' : 'Enter a location';
    }
    return _online && !place.contains('://')
        ? 'Include ://, for example https://…'
        : null;
  }

  String? _limitError(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number < 1 || number > 500) {
      return 'Enter an integer from 1 to 500';
    }
    return number < _initial.count
        ? 'At least ${_initial.count} places are already taken'
        : null;
  }

  String? _dateError(String? _) {
    if (_date == null) return 'Choose a date';
    final combined = _combined;
    return widget.item == null &&
            combined != null &&
            !combined.isAfter(DateTime.now())
        ? 'Choose a future date and time'
        : null;
  }

  String? _timeError(String? _) {
    if (_time == null) return 'Choose a time';
    final combined = _combined;
    return widget.item == null &&
            combined != null &&
            !combined.isAfter(DateTime.now())
        ? 'Choose a future date and time'
        : null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _date ?? _initial.when,
      firstDate: DateTime(
        (_initial.when.year < now.year ? _initial.when.year : now.year) - 1,
      ),
      lastDate: DateTime(
        (_initial.when.year > now.year ? _initial.when.year : now.year) + 10,
      ),
    );
    if (!mounted) return;
    if (selected == null) return;
    setState(() {
      _date = selected;
      _dateText.text = formatDate(selected);
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.fromDateTime(_initial.when),
    );
    if (!mounted) return;
    if (selected == null) return;
    setState(() {
      _time = selected;
      _timeText.text =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _requestExit() async {
    if (_asking || _saving) return;
    _asking = true;
    final discard = await confirm(
      context,
      title: 'Discard changes?',
      message: 'Your unsaved changes will be lost.',
      action: 'Discard',
    );
    if (!mounted) return;
    _asking = false;
    if (discard != true) return;
    setState(() => _leaving = true);
    // Rebuild PopScope before requesting the allowed pop.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_form.currentState?.validate() ?? false)) return;
    final when = _combined;
    final category = _category;
    final limit = int.tryParse(_limit.text.trim());
    if (when == null || category == null || limit == null) return;
    final description = _description.text.trim();
    final result = _initial.copyWith(
      title: _title.text.trim(),
      place: _place.text.trim(),
      limit: limit,
      category: category,
      when: when,
      online: _online,
      description: description,
      clearDescription: description.isEmpty,
    );
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  @override
  Widget build(BuildContext context) => PopScope<Meeting>(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _requestExit();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'New session' : 'Edit session'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Session title'),
                  maxLength: 60,
                  validator: _titleError,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: (_) => _titleFocus.unfocus(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Category>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final category in Category.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  validator: (value) =>
                      value == null ? 'Select a category' : null,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _category = value),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online session'),
                  subtitle: const Text('Use a meeting link instead of a room'),
                  value: _online,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _online = value),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _place,
                  focusNode: _placeFocus,
                  enabled: !_saving,
                  decoration: InputDecoration(
                    labelText: _online ? 'Meeting link' : 'Location',
                  ),
                  validator: _placeError,
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                  onTapOutside: (_) => _placeFocus.unfocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limit,
                  focusNode: _limitFocus,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Maximum participants',
                  ),
                  validator: _limitError,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _dateFocus.requestFocus(),
                  onTapOutside: (_) => _limitFocus.unfocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateText,
                  focusNode: _dateFocus,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  validator: _dateError,
                  onTap: _pickDate,
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _timeFocus.requestFocus(),
                  onTapOutside: (_) => _dateFocus.unfocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeText,
                  focusNode: _timeFocus,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    suffixIcon: Icon(Icons.schedule),
                  ),
                  readOnly: true,
                  validator: _timeError,
                  onTap: _pickTime,
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                  onTapOutside: (_) => _timeFocus.unfocus(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  minLines: 3,
                  maxLines: 6,
                  validator: (_) => null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _descriptionFocus.unfocus(),
                  onTapOutside: (_) => _descriptionFocus.unfocus(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save session'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
