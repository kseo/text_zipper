// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of text_zipper;

/// Creates a [TextZipper] from the given [iterable] of String.
TextZipper<String> stringZipper(Iterable<String> iterable) =>
    new TextZipper<String>._makeZipper(new _StringTextZipperOps(), iterable);

/// Provides a two-dimensional text zipper data structure.
class TextZipper<T> {
  final T _toLeft;
  final T _toRight;
  final SnocList<T> _above;
  final ConsList<T> _below;
  final _TextZipperOps<T> _ops;

  /// Gets the text.
  T get text => _ops.join(lines);

  /// Gets the lines.
  Iterable<T> get lines => _above.snoc(currentLine).append(_below);

  /// Gets the text of the line at the given [row], without its line ending.
  T lineForRow(int row) {
    if (row < _above.length) {
      // FIXME: Optimize elementAt of SnocList. Find the row backwards.
      return _above.elementAt(row);
    } else if (row == _above.length) {
      return currentLine;
    } else {
      return _below.elementAt(row - _above.length - 1);
    }
  }

  Position get startPosition => new Position(0, 0);

  Position get endPosition =>
      new Position(lineCount - 1, lineLengthForRow(lineCount - 1));

  int lineLengthForRow(int row) => _ops.length(lineForRow(row));

  int get lineCount => _above.length + 1 + _below.length;

  /// Returns the text of the line at the cursor position.
  T get currentLine => _ops.append(_toLeft, _toRight);

  T get _nextLine => _below.head;

  T get _previousLine => _above.last;

  /// Returns the lengths of the lines.
  List<int> get lineLengths => []
    ..addAll(_above.map(_ops.length))
    ..add(_ops.length(currentLine))
    ..addAll(_below.map(_ops.length));

  int get _currentRow => _above.length;

  int get _currentColumn => _ops.length(_toLeft);

  /// Returns the cursor position of the zipper.
  Position get cursorPosition => new Position(_currentRow, _currentColumn);

  /// Returns `true` if the cursor is at the first line.
  bool get isAtFirstLine => _above.isEmpty;

  /// Returns `true` if the cursor is at the last line.
  bool get isAtLastLine => _below.isEmpty;

  factory TextZipper._makeZipper(_TextZipperOps func, Iterable<T> iterable) {
    final empty = func.empty;
    final first = iterable.isEmpty ? empty : iterable.first;
    final rest = iterable.isEmpty ? iterable : iterable.skip(1);

    return new TextZipper<T>._(empty, first, new SnocList<T>.empty(),
        new ConsList<T>.from(rest), func);
  }

  TextZipper._(
      this._toLeft, this._toRight, this._above, this._below, _TextZipperOps ops)
      : _ops = checkNotNull(ops);

  TextZipper _new(
          {T toLeft, T toRight, SnocList<T> above, ConsList<T> below}) =>
      new TextZipper<T>._(toLeft ?? _toLeft, toRight ?? _toRight,
          above ?? _above, below ?? _below, _ops);

  /// Moves the cursor to the beginning of the current line.
  TextZipper moveToBeginningOfLine() =>
      _new(toLeft: _ops.empty, toRight: currentLine);

  /// Moves the cursor to the end of the current line.
  TextZipper moveToEndOfLine() =>
      _new(toLeft: currentLine, toRight: _ops.empty);

  /// Moves  the cursor to the left by one column.
  ///
  /// If the cursor is at the beginning of a line, the cursor is moved to
  /// the end of the preceding line (if any).
  TextZipper moveLeft() {
    if (_ops.isNotEmpty(_toLeft)) {
      return _new(
          toLeft: _ops.init(_toLeft),
          toRight:
              _ops.append(_ops.fromCharCode(_ops.last(_toLeft)), _toRight));
    } else if (!isAtFirstLine) {
      return _new(
          above: _above.init,
          below: new ConsList<T>(currentLine, _below),
          toLeft: _previousLine,
          toRight: _ops.empty);
    } else {
      return this;
    }
  }

  /// Moves the cursor to the right by one column.
  ///
  /// If the cursor is at the end of a line, the cursor is moved to the
  /// beginning of the following line (if any).
  TextZipper moveRight() {
    if (_ops.isNotEmpty(_toRight)) {
      return _new(
          toLeft: _ops.append(_toLeft, _ops.take(1, _toRight)),
          toRight: _ops.skip(1, _toRight));
    } else if (!isAtLastLine) {
      return _new(
          above: _above.snoc(_toLeft),
          below: _below.tail,
          toLeft: _ops.empty,
          toRight: _nextLine);
    } else {
      return this;
    }
  }

  /// Moves the cursor up by one row.
  ///
  /// If the row above is shorter, move to the end of that row.
  TextZipper moveUp() {
    if (isAtFirstLine) {
      return this;
    }

    if (_ops.length(_previousLine) >= _ops.length(_toLeft)) {
      return _new(
          above: _above.init,
          below: _below.cons(currentLine),
          toLeft: _ops.take(_currentColumn, _previousLine),
          toRight: _ops.skip(_currentColumn, _previousLine));
    } else {
      return _new(
          above: _above.init,
          below: _below.cons(currentLine),
          toLeft: _previousLine,
          toRight: _ops.empty);
    }
  }

  /// Moves the cursor down by one row.
  ///
  /// If the row below is shorter, move to the end of that row.
  TextZipper moveDown() {
    if (isAtLastLine) {
      return this;
    }

    if (_ops.length(_nextLine) >= _ops.length(_toLeft)) {
      return _new(
          above: _above.snoc(currentLine),
          below: _below.tail,
          toLeft: _ops.take(_currentColumn, _nextLine),
          toRight: _ops.skip(_currentColumn, _nextLine));
    } else {
      return _new(
          above: _above.snoc(currentLine),
          below: _below.tail,
          toLeft: _nextLine,
          toRight: _ops.empty);
    }
  }

  bool _isValidPosition(Position position) =>
      position.row >= 0 &&
      position.row < lineCount &&
      position.column >= 0 &&
      position.column <= lineLengthForRow(position.row);

  TextZipper _traverse(Position delta) {
    final position = cursorPosition.traverse(delta);
    if (!_isValidPosition(position)) {
      return this;
    }

    var newAbove = _above;
    var newBelow = _below;
    var newCurrentLine = currentLine;

    if (delta.row > 0) {
      newAbove = _above.snoc(currentLine).append(_below.take(delta.row - 1));
      final below = _below.skip(delta.row - 1);
      newCurrentLine = below.head;
      newBelow = below.tail;
    } else if (delta.row < 0) {
      final above = _above.skipRight(delta.row - 1);
      newAbove = above.init;
      newCurrentLine = _above.last;
      newBelow = _below
          .cons(currentLine)
          .prependReversed(_above.takeRightReversed(delta.row - 1));
    }

    return _new(
        above: newAbove,
        below: newBelow,
        toLeft: _ops.take(position.column, newCurrentLine),
        toRight: _ops.skip(position.column, newCurrentLine));
  }

  /// Moves the cursor to the top of the zipper.
  TextZipper moveToTop() => moveCursorTo(startPosition);

  /// Moves the cursor to the bottom of the zipper.
  TextZipper moveToBottom() => moveCursorTo(endPosition);

  /// Moves the cursor to the specified [newPosition].
  ///
  /// Invalid cursor positions will be ignored.
  TextZipper moveCursorTo(Position newPosition) {
    if (!_isValidPosition(newPosition)) {
      return this;
    }

    final delta = newPosition.traversalFrom(cursorPosition);
    return _traverse(delta);
  }

  /// Inserts the character at the current cursor position. Moves the cursor
  /// one column to the right.
  TextZipper insertCharCode(int charCode) {
    if (charCode == '\n'.codeUnitAt(0)) {
      return newLine();
    }

    return _new(toLeft: _ops.append(_toLeft, _ops.fromCharCode(charCode)));
  }

  /// Deletes the character at the cursor position.
  ///
  /// If the cursor is at the end of a line, combines the line with the
  /// following line.
  TextZipper deleteChar() {
    if (_ops.isNotEmpty(_toRight)) {
      return _new(toRight: _ops.skip(1, _toRight));
    } else if (_ops.isEmpty(_toRight) && !isAtLastLine) {
      return _new(toRight: _nextLine, below: _below.tail);
    } else {
      return this;
    }
  }

  /// Deletes the character preceding the cursor position.
  TextZipper backspace() {
    if (moveLeft() == this) {
      return this;
    } else {
      return moveLeft().deleteChar();
    }
  }

  /// Inserts a line break at the current cursor position.
  TextZipper newLine() => _new(toLeft: _ops.empty, above: _above.snoc(_toLeft));
}
