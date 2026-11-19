import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: _body(m),
    );
  }

  Widget _body(UsersModel m) {
    // Full-screen spinner only when there is nothing to show yet;
    // on pull-to-refresh the RefreshIndicator shows its own spinner.
    if (m.loading && m.items.isEmpty) return const LoadingView();
    // Exhaustive: ApiException is sealed, so there is no `default`.
    return switch (m.error) {
      null => UserList(m.items),
      NoConnectionException() => MessageView(
          icon: Icons.wifi_off,
          text: 'No connection',
          onRetry: m.load,
        ),
      NotFoundException() || UnauthorizedException() => const MessageView(
          icon: Icons.block,
          text: 'The server refused the request',
        ),
      ServerException(:final status) => MessageView(
          icon: Icons.cloud_off,
          text: 'Server error ($status)',
          onRetry: m.load,
        ),
      BadResponseException() => const MessageView(
          icon: Icons.bug_report,
          text: 'Unreadable response from the server',
        ),
    };
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class MessageView extends StatelessWidget {
  const MessageView({
    required this.icon,
    required this.text,
    this.onRetry,
    super.key,
  });

  final IconData icon;
  final String text;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56),
          const SizedBox(height: 12),
          Text(text),
          if (retry != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: retry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<UsersModel>().load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text('${u.email}\n${u.address.city}'),
            isThreeLine: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: u),
              ),
            ),
          );
        },
      ),
    );
  }
}
