// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of text_zipper;

abstract class _TextZipperOps<T> {
  T get empty;
  T append(T xs, T ys);
  T join(Iterable<T> iterable);

  int length(T xs);

  bool isEmpty(T xs);
  bool isNotEmpty(T xs) => !isEmpty(xs);

  T take(int n, T xs);
  T skip(int n, T xs);
  T takeRight(int n, T xs);
  T skipRight(int n, T xs);

  int last(T xs);
  T init(T xs);

  T fromCharCode(int codeUnit);
}

class _StringTextZipperOps extends _TextZipperOps<String> {
  @override
  String get empty => '';

  @override
  String append(String xs, String ys) => xs + ys;

  @override
  String join(Iterable<String> iterable) => iterable.join('\n');

  @override
  bool isEmpty(String xs) => xs.isEmpty;

  @override
  int length(String xs) => xs.length;

  @override
  String fromCharCode(int charCode) => new String.fromCharCode(charCode);

  @override
  String take(int n, String xs) => xs.substring(0, n);

  @override
  String skip(int n, String xs) => xs.substring(n, xs.length);

  @override
  String takeRight(int n, String xs) => xs.substring(xs.length - n, xs.length);

  @override
  String skipRight(int n, String xs) => xs.substring(0, xs.length - n);

  @override
  int last(String xs) => xs.codeUnitAt(xs.length - 1);

  @override
  String init(String xs) => xs.substring(0, xs.length - 1);
}
