import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});
  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _manual = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('A · StreamBuilder')),
              ButtonSegment(value: true, label: Text('B · Subscription')),
            ],
            selected: {_manual},
            onSelectionChanged: (value) =>
                setState(() => _manual = value.single),
          ),
          const SizedBox(height: 24),
          const Text('10 → 0 · one tick per second'),
          // Only the selected child is mounted. Switching cancels the old one.
          Expanded(
            child: _manual
                ? const SubscriptionCountdown()
                : const BuilderCountdown(),
          ),
          const Text(
            'Go back at 7. The subscription stops when you leave.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

class BuilderCountdown extends StatefulWidget {
  const BuilderCountdown({super.key});
  @override
  State<BuilderCountdown> createState() => _BuilderCountdownState();
}

class _BuilderCountdownState extends State<BuilderCountdown> {
  late final Stream<int> _stream = countdown(10);
  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _stream,
    builder: (context, snapshot) =>
        CountdownValue(snapshot.data ?? 10, label: 'StreamBuilder'),
  );
}

class SubscriptionCountdown extends StatefulWidget {
  const SubscriptionCountdown({super.key});
  @override
  State<SubscriptionCountdown> createState() => _SubscriptionCountdownState();
}

class _SubscriptionCountdownState extends State<SubscriptionCountdown> {
  int _left = 10;
  late StreamSubscription<int> _sub;
  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    // Lifecycle methods are synchronous. Cancellation starts immediately;
    // the Future only represents completion of generator cleanup.
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CountdownValue(_left, label: 'StreamSubscription');
}

class CountdownValue extends StatelessWidget {
  const CountdownValue(this.value, {super.key, required this.label});
  final int value;
  final String label;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 48),
        const SizedBox(height: 24),
        Text('$value', style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 16),
        Text(label),
        const SizedBox(height: 8),
        Text(value == 0 ? 'Finished' : 'Counting down'),
      ],
    ),
  );
}
