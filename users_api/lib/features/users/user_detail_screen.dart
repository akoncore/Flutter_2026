import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _row('Username', user.username),
          _row('Email', user.email),
          // Practice 12 will open these with url_launcher.
          _row('Phone', user.phone, onTap: () {}),
          _row('Website', website ?? '—', onTap: website == null ? null : () {}),
          _row('Address', '${a.street}, ${a.suite}\n${a.city} ${a.zipcode}'),
          _row('Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _row('Company', '${user.company.name}\n"${user.company.catchPhrase}"'),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {VoidCallback? onTap}) => ListTile(
        title: Text(title),
        subtitle: Text(value),
        onTap: onTap,
      );
}
