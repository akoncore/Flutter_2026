import 'package:flutter/material.dart';
import 'models/meeting.dart';
import 'models/profile.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArguments {
  const DetailArguments({
    required this.item,
    required this.profile,
    required this.onChanged,
    required this.onDeleted,
    required this.onTab,
  });
  final Meeting item;
  final Profile profile;
  final ValueChanged<Meeting> onChanged;
  final ValueChanged<String> onDeleted;
  final ValueChanged<int> onTab;
}

class FormArguments {
  const FormArguments({this.item});
  final Meeting? item;
}
