library side_enum_test;

import "package:test/test.dart";

import "package:diff/diff.dart";

void defineTests() {
  group('Side', () {
    test('enum compare', () {
      Side conflict = Side.CONFLICT;
      Side left = Side.LEFT;
      int i = conflict.compareTo(left);
      expect(i, equals(-1));

      conflict = Side.CONFLICT;
      left = Side.LEFT;
      i = left.compareTo(conflict);
      expect(i, equals(1));

      conflict = Side.CONFLICT;
      Side conflict2 = Side.CONFLICT;
      i = conflict.compareTo(conflict2);
      expect(i, equals(0));
    });

    test('enum equal', () {
      Side conflict = Side.CONFLICT;
      expect(conflict, equals(Side.CONFLICT));
    });
  });
}

void main() {
  defineTests();
}
