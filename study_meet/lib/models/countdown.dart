sealed class Countdown {
  const Countdown();
  factory Countdown.at(DateTime start, DateTime now) {
    if (now.isBefore(start)) return Upcoming(start.difference(now));
    final elapsed = now.difference(start);
    return elapsed < const Duration(hours: 2)
        ? Started(elapsed)
        : const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);
  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}
