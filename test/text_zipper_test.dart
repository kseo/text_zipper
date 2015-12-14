// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library text_zipper.test;

import 'package:text_zipper/text_zipper.dart';
import 'package:test/test.dart';

const String text = '''
123
abcdef
ABC

!@#''';

void main() {
  group('A group of tests', () {
    TextZipper<String> tz = stringZipper(text);

    group('Query', () {
      test('lineCount', () {
        expect(tz.lineCount, equals(5));
      });

      test('lineForRow', () {
        expect(tz.lineForRow(0), equals('123'));
        expect(tz.lineForRow(1), equals('abcdef'));
        expect(tz.lineForRow(2), equals('ABC'));
        expect(tz.lineForRow(3), equals(''));
        expect(tz.lineForRow(4), equals('!@#'));
      });

      test('lines', () {
        expect(tz.lines, orderedEquals(['123', 'abcdef', 'ABC', '', '!@#']));
      });

      test('text', () {
        expect(tz.text, equals(text));
      });

      test('lineLengthForRow', () {
        expect(tz.lineLengthForRow(0), equals(3));
        expect(tz.lineLengthForRow(1), equals(6));
        expect(tz.lineLengthForRow(2), equals(3));
        expect(tz.lineLengthForRow(3), equals(0));
        expect(tz.lineLengthForRow(4), equals(3));
      });

      test('lineLengths', () {
        expect(tz.lineLengths,
            orderedEquals(text.split('\n').map((x) => x.length)));
      });
    });

    group('Cursor', () {
      test('initial position', () {
        expect(tz.cursorPosition, equals(tz.startPosition));
      });

      test('isAtFirstLine/isAtLastLine', () {
        final tzStart = tz.moveToTop();
        final tzEnd = tz.moveToBottom();

        expect(tzStart.isAtFirstLine, isTrue);
        expect(tzStart.isAtLastLine, isFalse);

        expect(tzEnd.isAtFirstLine, isFalse);
        expect(tzEnd.isAtLastLine, isTrue);
      });

      test('moveUp', () {
        final tz1 = tz.moveToTop();
        final tz2 = tz.moveCursorTo(new Position(1, 2));
        final tz3 = tz.moveCursorTo(new Position(1, 4));

        expect(tz1.moveUp().cursorPosition, equals(tz1.startPosition));
        expect(tz2.moveUp().cursorPosition, equals(new Position(0, 2)));
        expect(tz3.moveUp().cursorPosition, equals(new Position(0, 3)));
      });

      test('moveDown', () {
        final tz1 = tz.moveToBottom();
        final tz2 = tz.moveCursorTo(new Position(1, 2));
        final tz3 = tz.moveCursorTo(new Position(1, 4));

        expect(tz1.moveDown().cursorPosition, equals(tz1.endPosition));
        expect(tz2.moveDown().cursorPosition, equals(new Position(2, 2)));
        expect(tz3.moveDown().cursorPosition, equals(new Position(2, 3)));
      });

      test('moveLeft', () {
        final tz1 = tz.moveToTop();
        final tz2 = tz.moveCursorTo(new Position(1, 0));
        final tz3 = tz.moveCursorTo(new Position(1, 4));

        expect(tz1.moveLeft().cursorPosition, equals(tz1.startPosition));
        expect(tz2.moveLeft().cursorPosition, equals(new Position(0, 3)));
        expect(tz3.moveLeft().cursorPosition, equals(new Position(1, 3)));
      });

      test('moveRight', () {
        final tz1 = tz.moveToBottom();
        final tz2 = tz.moveCursorTo(new Position(1, 6));
        final tz3 = tz.moveCursorTo(new Position(1, 4));

        expect(tz1.moveRight().cursorPosition, equals(tz1.endPosition));
        expect(tz2.moveRight().cursorPosition, equals(new Position(2, 0)));
        expect(tz3.moveRight().cursorPosition, equals(new Position(1, 5)));
      });
    });

    group('Editing', () {
      test('insertCharCode at the beginning of a line', () {
        final ntz = tz.insertCharCode('x'.codeUnitAt(0));
        expect(ntz.lineForRow(0), equals('x123'));
      });

      test('insertCharCode in the middle', () {
        final ntz = tz.moveRight().insertCharCode('x'.codeUnitAt(0));
        expect(ntz.lineForRow(0), equals('1x23'));
      });

      test('insertCharCode at the end of a line', () {
        final ntz = tz.moveToEndOfLine().insertCharCode('x'.codeUnitAt(0));
        expect(ntz.lineForRow(0), equals('123x'));
      });

      test('deleteChar at the beginning of a line', () {
        final ntz = tz.deleteChar();
        expect(ntz.lineForRow(0), equals('23'));
      });

      test('deleteChar in the middle', () {
        final ntz = tz.moveRight().deleteChar();
        expect(ntz.lineForRow(0), equals('13'));
      });

      test('deleteChar at the end of a line', () {
        final ntz = tz.moveToEndOfLine().deleteChar();
        expect(ntz.lineForRow(0), equals('123abcdef'));
      });

      test('deleteChar at the end of a buffer', () {
        final ntz = tz.moveToBottom().deleteChar();
        expect(ntz.lineForRow(4), equals('!@#'));
      });

      test('deleteChar at the start of a buffer', () {
        final ntz = tz.moveToTop().backspace();
        expect(ntz.lineForRow(0), equals('123'));
      });

      test('backspace at the beginning of a line', () {
        final ntz = tz.moveDown().backspace();
        expect(ntz.lineForRow(0), equals('123abcdef'));
      });

      test('backspace in the middle', () {
        final ntz = tz.moveDown().moveRight().backspace();
        expect(ntz.lineForRow(1), equals('bcdef'));
      });

      test('backspace at the end of a line', () {
        final ntz = tz.moveDown().moveToEndOfLine().backspace();
        expect(ntz.lineForRow(1), equals('abcde'));
      });
    });
  });
}
