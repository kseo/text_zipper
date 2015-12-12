// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of text_zipper;

class Position {
  final int row;
  final int column;

  Position(this.row, this.column);

  Position traverse(Position other) => new Position(row + other.row,
      other.row == 0 ? column + other.column : other.column);

  Position traversalFrom(Position other) => (row == other.row)
      ? new Position(0, column - other.column)
      : new Position(row - other.row, column);

  @override
  bool operator ==(o) => o is Position && row == o.row && column == o.column;

  @override
  int get hashCode => row * 17 + column;

  @override
  String toString() => '($row, $column)';
}
