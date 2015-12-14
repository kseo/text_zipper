# text_zipper

A two dimensional text zipper data structure. It uses [The Zipper][zipper] data structure to implement a purely functional text buffer.

[zipper]: https://www.st.cs.uni-saarland.de/edu/seminare/2005/advanced-fp/docs/huet-zipper.pdf

## Usage

```dart
import 'package:text_zipper/text_zipper.dart';

main() {
  const String text = '''
abc
df
efg''';

  var tz = stringZipper(text);
  tz = tz.moveCursorTo(new Position(1, 1)).insertCharCode('e'.codeUnitAt(0));
  print(tz.text);
  /// abc
  /// def
  /// efg
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kseo/text_zipper/issues
