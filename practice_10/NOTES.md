# Practice 10 — observations

## Level 1: later means later

Prediction: A, C, first frame, then after two seconds B and 6 students.
Observed by `event order` widget test: **A, C, first frame, B, 6 students**.
The API also logs `fetchStudents #1` synchronously when the request starts.
The frame is recorded by a test Builder, not a print statement in production.

The real blocking-sleep experiment measured **2001 ms** before a queued event
could run. During sleep that event had not run; after awaiting its Future it
had. The production API uses Future.delayed, never sleep.

The third sequential fetch reached the isolated test zone as:

```text
Unhandled Exception: Instance of 'NoConnectionException'
```

The test zone captures the exception so the test runner can continue. Actual
uncaught errors may terminate an isolate; a Flutter app can keep displaying
its previous frame, but an unhandled exception is not successful handling.

Each request captures its number before await. Otherwise three overlapping
requests could all read the final mutable calls value of 3 and all fail.
The concurrent-request test confirms two successes and one failure.

## Level 2: four states and a disposed State

Observed: loading for two seconds, six students, error on request 3, and
successful Retry on request 4. Empty mode shows No students yet. Aruzhan's
missing GPA displays an em dash. Both screen implementations can be removed
while a request is pending without an exception.

The isolated probe without a mounted guard produced this actual first line
(the hash varies on each run):

```text
setState() called after dispose(): _BrokenProbeState#8cbb9(lifecycle state: defunct, not mounted)
```

The test catches the thrown error at the callback boundary and verifies its
text. Production checks mounted in both the success and catch paths.

## Level 3: one Future, independent rebuilds

Ten Switch toggles after loading left `api.calls == 1`. Reloads produced
fetchStudents #2, #3 (error), then Retry #4 (data). Empty responses were also
tested. `_future` is late, not final, because explicit retry replaces it.

Two details matter:

- `setState(() => _future = _api.fetchStudents())` returns the assigned Future.
  In debug mode Flutter reports `setState() callback argument returned a Future.`
  The implementation uses a block callback with no return value.
- A FutureBuilder can retain an old error when its Future changes. An
  `ObjectKey(_future)` resets that snapshot on retry, so the error-first branch
  still allows the new request's loading indicator. A density change preserves
  both the Future and key.

For manual comparison, creating a Future inline in build starts a request on
any density change. A builder that handles only hasData and otherwise returns
a spinner has no error branch, so a failed Future keeps displaying the spinner.
These two variants are explanations/reproduction instructions, not additional
recorded UI measurements. They are absent from production.

## Level 4: ownership of streams

Both versions emitted 10 through 0 in widget tests. Since the required loop
waits before yielding 10, the initial 10 stays visible for the first second;
zero arrives on the eleventh second.

Observed with explicit cancellation: tick 10, tick 9, tick 8, tick 7; after
removing version B, nine more simulated seconds produced no tick or exception.
Observed with StreamBuilder: the same sequence and silence after disposal;
StreamBuilder cancelled its own subscription.

Without cancel in the isolated probe: tick 6, tick 5, tick 4, tick 3, tick 2,
tick 1, tick 0 continued after removal at 7. Each callback attempted setState
on a dead State. The first actual error was:

```text
setState() called after dispose(): _BrokenProbeState#b5bb7(lifecycle state: defunct, not mounted)
```

The test catches those intentional errors and drains the stream. The actual
SubscriptionCountdown calls cancel before super.dispose. Switching segments
unmounts the old version; an invisible countdown is not retained in a tab.

## Level 5: save failures must reach the user

The deliberately unawaited second save recorded apparent success first and
then the zone received:

```text
Unhandled Exception: Bad state: server rejected 6
```

The user saw a success although the server rejected the save. The isolated
test models this with an apparentSuccess flag; it does not falsely report a
real successful save. Production awaits save, catches StateError, checks
context.mounted, and pops only on success. A rejected save displays the exact
server message and leaves the list open. Tests confirm the disabled button
prevents a second submission, and leaving during save causes no context error.

The home State retains API instances across route visits. Constructing a new
API on every visit would reset saveCalls, making the described second-save
failure impossible after a successful pop.

`unawaited_futures` is enabled. Contrary to the handout's synchronous callback
example, this rule checks async function bodies; it does not flag every Future
discarded inside a synchronous callback. An async callback without await is a
reliable lint reproduction. Production awaits save and navigation. Synchronous
initState/dispose explicitly use unawaited for the handled load and stream
cancellation: these framework lifecycle methods cannot themselves be async.

## Verification

- Flutter 3.47.4, Dart 3.13.3.
- `dart format .`: completed.
- `flutter analyze`: No issues found!, with unawaited_futures enabled.
- `flutter test`: all 13 tests passed, including isolated negative experiments.
- `flutter build web`: succeeded.
- Headless Microsoft Edge at 430 x 932: real application loaded, request 3
  showed ErrorView, Retry restored the list, B reached 7, Back returned home;
  no browser page errors were recorded.
- screenshot_error.png and screenshot_countdown.png are browser captures of
  the actual Flutter app, not mockups. Android files are included; an Android
  emulator/device run is not claimed.

## References

- [FutureBuilder lifecycle and retained snapshots](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)
- [The exact scope of unawaited_futures](https://dart.dev/tools/linter-rules/unawaited_futures)
- [Futures and async/await](https://dart.dev/libraries/async/async-await)
- [Using streams](https://dart.dev/libraries/async/using-streams)
