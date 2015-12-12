// Copyright (c) 2015, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library text_zipper.cons_list;

import 'dart:collection';

import 'package:quiver_check/check.dart';

abstract class FunctionalList<T> implements Iterable<T> {
  bool get isEmpty;

  bool get isNotEmpty;

  int get length;

  T get head;

  T get last;

  FunctionalList<T> get tail;

  FunctionalList<T> get init;

  /// Prepends the given [element] to the list.
  FunctionalList<T> cons(T element);

  /// Appends the given [element] to the list.
  FunctionalList<T> snoc(T element);

  FunctionalList<T> prependReversed(Iterable<T> other);

  /// Appends all elements of [other] list to this list.
  FunctionalList<T> append(Iterable<T> other);

  Iterable<T> take(int n);
  Iterable<T> takeRightReversed(int n);

  FunctionalList<T> skip(int n);
  FunctionalList<T> skipRight(int n);
}

class SnocList<T> extends IterableBase<T> implements FunctionalList<T> {
  final T _last;
  final SnocList<T> _init;
  final int _length;

  @override
  bool get isEmpty => _last == null;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  int get length => _length;

  @override
  T get head => _useConsList();

  @override
  T get last => _last;

  @override
  FunctionalList<T> get init => _init;

  @override
  FunctionalList<T> get tail => _useConsList();

  @override
  Iterator<T> get iterator => new _SnocListIterator<T>(this);

  SnocList.empty()
      : _init = null,
        _last = null,
        _length = 0;

  SnocList(SnocList<T> init, T last)
      : _init = checkNotNull(init),
        _last = checkNotNull(last),
        _length = 1 + init.length;

  factory SnocList.single(T element) =>
      new SnocList<T>(new SnocList<T>.empty(), element);

  factory SnocList.from(Iterable<T> iterable) => iterable.fold(
      new SnocList<T>.empty(), (snocList, element) => snocList.snoc(element));

  @override
  FunctionalList<T> cons(T element) => _useConsList();

  @override
  FunctionalList<T> snoc(T element) => new SnocList(this, element);

  @override
  FunctionalList<T> prependReversed(Iterable<T> other) => _useConsList();

  @override
  FunctionalList<T> append(Iterable<T> other) =>
      other.fold(this, (snocList, element) => snocList.snoc(element));

  @override
  Iterable<T> take(int n) => _useConsList();

  @override
  Iterable<T> takeRightReversed(int n) {
    var list = this;
    final result = [];
    while (n > 0) {
      result.add(list.last);
      list = list.init;
      n--;
    }
    return result;
  }

  @override
  FunctionalList<T> skip(int n) => _useConsList();

  @override
  FunctionalList<T> skipRight(int n) {
    var list = this;
    while (n > 0) {
      list = list.init;
      n--;
    }
    return list;
  }

  ConsList<T> toConsList() => new ConsList.from(this);

  dynamic _useConsList() => throw new UnsupportedError(
      'Use ConsList if you need an efficient implementation of this method');
}

class ConsList<T> extends IterableBase<T> implements FunctionalList<T> {
  final T _head;
  final ConsList<T> _tail;
  final int _length;

  @override
  bool get isEmpty => _head == null;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  int get length => _length;

  @override
  T get head => _head;

  @override
  T get last => _useSnocList();

  @override
  FunctionalList<T> get tail => _tail;

  @override
  FunctionalList<T> get init => _useSnocList();

  @override
  Iterator<T> get iterator => new _ConsListIterator<T>(this);

  ConsList.empty()
      : _head = null,
        _tail = null,
        _length = 0;

  ConsList(T head, ConsList<T> tail)
      : _head = checkNotNull(head),
        _tail = checkNotNull(tail),
        _length = 1 + tail.length;

  factory ConsList.single(T element) =>
      new ConsList<T>(element, new ConsList<T>.empty());

  factory ConsList.from(Iterable<T> iterable) => _foldr(iterable,
      new ConsList<T>.empty(), (element, consList) => consList.cons(element));

  @override
  FunctionalList<T> cons(T element) => new ConsList<T>(element, this);

  @override
  FunctionalList<T> snoc(T element) => _useSnocList();

  @override
  FunctionalList<T> prependReversed(Iterable<T> other) =>
    other.fold(this, (consList, element) => consList.cons(element));

  @override
  FunctionalList<T> append(Iterable<T> other) => _useSnocList();

  @override
  Iterable<T> take(int n) {
    var list = this;
    final result = [];
    while (n > 0) {
      result.add(list.head);
      list = list.tail;
      n--;
    }
    return result;
  }

  @override
  Iterable<T> takeRightReversed(int n) => _useSnocList();

  @override
  FunctionalList<T> skip(int n) {
    var list = this;
    while (n > 0) {
      list = list.tail;
      n--;
    }
    return list;
  }

  @override
  FunctionalList<T> skipRight(int n) => _useSnocList();

  SnocList<T> toSnocList() => new SnocList.from(this);

  dynamic _useSnocList() => throw new UnsupportedError(
      'Use SnocList if you need an efficient implementation of this method');
}

class _SnocListIterator<T> implements Iterator<T> {
  Iterator<T> _iterator;

  _SnocListIterator(SnocList<T> list) {
    List<T> elements = [];
    while (list.isNotEmpty) {
      elements.insert(0, list.last);
      list = list.init;
    }
    _iterator = elements.iterator;
  }

  T get current => _iterator.current;

  bool moveNext() => _iterator.moveNext();
}

class _ConsListIterator<T> implements Iterator<T> {
  T _current;
  ConsList<T> _list;

  _ConsListIterator(this._list);

  T get current => _current;

  bool moveNext() {
    if (_list.isNotEmpty) {
      _current = _list.head;
      _list = _list.tail;
      return true;
    } else {
      return false;
    }
  }
}

dynamic _foldr(
    Iterable iterable, initialValue, dynamic combine(element, previousValue)) {
  var value = initialValue;
  for (final element in iterable.toList().reversed) {
    value = combine(element, value);
  }
  return value;
}
