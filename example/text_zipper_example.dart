// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library text_zipper.example;

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

