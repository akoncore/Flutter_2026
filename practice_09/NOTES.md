# Practice 9 notes

## Level 1
Adding total to the badge changes two constructors: BooksScreen in
lib/books_screen.dart and CartBadge in lib/cart_badge.dart. Three files change:
those two plus lib/main.dart, where Shell calculates and passes total.
No new parameter is needed on Shell, AppBar or CartScreen.

One Add triggers one BooksScreen build and six row messages: seven lines.
The widget test checks the actual counts and the two-route add/remove flow.

MaterialApp retains routes. Simply replacing its routes map does not force
existing route builders to rerun. A small inherited revision signal invalidates
both route builders while state stays in Shell and data uses parameters.

## Level 2 — A model without widgets

Cart keeps its collection private. Its public items getter returns an immutable
snapshot, so callers cannot bypass notifications. The original list design
evolves to Map<Book, int> for Level 4. A model-only test adds the first two books,
rejects the duplicate, removes the first, and verifies `1 items, 3100 ₸`.
Trying `cart.items.add(books[0])` throws UnsupportedError.

Only add decides whether a duplicate is allowed. Widgets display membership;
they do not implement the mutation rule. Successful mutations notify once.
Duplicate add and other no-op operations do not notify. Increment of an absent
book does nothing; it does not silently re-add a removed book.

The only Flutter import in cart.dart is foundation.dart. The additional local
book.dart import is needed to name Book, which the assignment requires in a
separate file. No material.dart, BuildContext, navigation or UI dependencies
appear in models. ChangeNotifier still needs Flutter foundation, so this is a
widget-free model, not a package-free standalone Dart library.

A required BuildContext constructor argument would prevent constructing Cart()
before runApp. Merely declaring an optional context field would not itself
cause a compile error; the real issue is coupling data to a widget lifetime.

## Level 3 — Provider and the two broken verbs

ChangeNotifierProvider(create: (_) => Cart()) owns a single model above
MaterialApp. Shell is stateless. No cart data or callbacks pass through screen
constructors. The Cart list is a Consumer; its callbacks use the supplied cart.

The deliberate watch-in-onPressed test captures this provider assertion:

> Tried to listen to a value exposed with provider, from outside of the widget tree.

Use context.read<Cart>() in event handlers. The negative test is intentionally
isolated in test/subscriptions_test.dart, never used by the production app.

The other error is silent: using read in build registers no dependency. There
is NO exception text. The displayed count remains stale until something else
rebuilds the widget. A read probe starts at 1 and still displays 1 after removal;
the equivalent badge starting with an empty cart would stay at 0 after Add.
It is not necessarily frozen forever: an unrelated rebuild can refresh it.

Level 3 watch is retained as a measured test variant. The final Level 4 badge
uses select, and each BookRow selects only its own membership boolean.

## Level 4 — Measured subscription scope

These are actual automated widget build measurements, excluding initial builds;
they are not claimed as screenshots of the DevTools performance panel.

| Experiment | Measured builds |
| --- | ---: |
| Lifted Add, BooksScreen | 1 |
| Lifted Add, all book rows | 6 |
| Provider Add, BooksScreen | 0 |
| Provider Add, affected book row | 1 |
| watch count, three separate quantity increments | 3 |
| select count, three separate quantity increments | 0 |
| select count, remove one distinct book | 1 |
| Production badge, three + taps on Cart route | 0 |
| Book rows, three + taps on Cart route | 0 |
| Consumer static total label, three + taps | 0 |

The total preview has a separate subscription to total. Putting total in the
same badge build would force quantity changes to rebuild that widget, defeating
the count-only experiment. The Cart total uses Consumer.child for a const icon
and label, passing child! through its builder. Count means distinct titles;
total is the sum of unit price multiplied by quantity.

To reproduce visually: run in debug/profile mode, enable Track widget builds
in DevTools Performance (or Track widget rebuilds in Android Studio), add a
book, open Cart, then press + three times. Temporarily change the badge's
select expression to `context.watch<Cart>().count` for the watch comparison.
Restore select afterwards. To observe a broad dependency, temporarily put
`context.watch<Cart>()` in BooksScreen.build: it invalidates that screen on
every notification and rebuilds its newly constructed row widgets. This last
manual experiment is a reproduction instruction, not an additional recorded
measurement.

## Level 5 — Logic and presentation

add returns bool; the BookRow callback displays Added only for true. Duplicate
add is false, does not notify and cannot cause another success SnackBar. The
Added row has no Add button. The cart icon clears pending success SnackBars
before navigating, so they cannot obscure the Cart total controls.

Clear cart asks with showDialog<bool>, checks context.mounted after await and
clears only on true. Cancel or dismiss leaves the cart alone. The model never
opens dialogs or SnackBars. Search matches titles and authors without case
sensitivity; a local bool controls whether the total is expanded.

### Where does it live?

- Cart — provided: shared across routes; one owner above MaterialApp. Level 1 used lifted state in Shell.
- Search text — ephemeral: only the Books screen needs it; stored in its State.
- Total expanded or collapsed — ephemeral: presentation state local to CartScreen.
- Theme mode for a hypothetical switch — provided at the app root: MaterialApp and settings across routes need it; persist separately if desired.

## Verification and evidence

Flutter 3.47.4, Dart 3.13.3, provider 6.1.5+1.
`dart format .` completed. `flutter analyze` reported `No issues found!`.
All seven final tests passed. The lifted commit's test also passed before
migration. `flutter build web` succeeded. `flutter run -d web-server` served
the actual app and headless Edge exercised the production UI at 430 × 932.

- screenshot_books.png: first two books added, badge 2, total 7300 ₸.
- screenshot_cart.png: first title quantity 2, second quantity 1, total 11500 ₸.

The screenshots show the running Flutter app, not mockups. Android platform
files are included; no Android device run is claimed. The supplied SDK launcher
initially stalled, so verification invoked its flutter_tools.snapshot through
the bundled Dart executable (the same Flutter tool).

## Sources

- https://docs.flutter.dev/data-and-backend/state-mgmt/simple
- https://pub.dev/packages/provider
- https://docs.flutter.dev/tools/devtools/performance
