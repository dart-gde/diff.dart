library test_runner;

import "package:unittest/unittest.dart";

import "package:diff/diff.dart";

tests() {
  test('Side enum compare', () {
    Side conflict = Side.Conflict;
    Side left = Side.Left;
    int i = conflict.compareTo(left);
    expect(i, equals(-1));

    conflict = Side.Conflict;
    left = Side.Left;
    i = left.compareTo(conflict);
    expect(i, equals(1));

    conflict = Side.Conflict;
    Side conflict2 = Side.Conflict;
    i = conflict.compareTo(conflict2);
    expect(i, equals(0));
  });

  test('Side enum equal', () {
    Side conflict = Side.Conflict;
    expect(conflict, equals(Side.Conflict));
  });
}

void main() {
  tests();
}