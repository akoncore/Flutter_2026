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
