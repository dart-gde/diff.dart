library diff3_set_test;

import "package:test/test.dart";

import "package:diff/diff.dart";

void defineTests() {
  group('diff3Set', () {
    test('sort file1offset not equal', () {
      List<Diff3Set> hunks = new List<Diff3Set>();
      Diff3Set s1 = new Diff3Set();
      s1..side = Side.CONFLICT
        ..file1length = 1
        ..file1offset = 1
        ..file2length = 1
        ..file2offset = 1;

      Diff3Set s2 = new Diff3Set();
      s2..side = Side.LEFT
        ..file1length = 2
        ..file1offset = 2
        ..file2length = 2
        ..file2offset = 2;

      hunks.add(s2);
      hunks.add(s1);

      hunks.sort();

      expect(hunks[0], equals(s1));
      expect(hunks[1], equals(s2));

    });

    test('sort file1offset equal, s2 greater then s1', () {
      List<Diff3Set> hunks = new List<Diff3Set>();
      Diff3Set s1 = new Diff3Set();
      s1..side = Side.CONFLICT
        ..file1length = 1
        ..file1offset = 1
        ..file2length = 1
        ..file2offset = 1;

      Diff3Set s2 = new Diff3Set();
      s2..side = Side.LEFT
        ..file1length = 2
        ..file1offset = 1
        ..file2length = 2
        ..file2offset = 2;

      hunks.add(s2);
      hunks.add(s1);

      hunks.sort();

      expect(hunks[0], equals(s1));
      expect(hunks[1], equals(s2));
    });

    test('sort file1offset equal, s1 greater then s2', () {
      List<Diff3Set> hunks = new List<Diff3Set>();
      Diff3Set s1 = new Diff3Set();
      s1..side = Side.LEFT
        ..file1length = 1
        ..file1offset = 1
        ..file2length = 1
        ..file2offset = 1;

      Diff3Set s2 = new Diff3Set();
      s2..side = Side.CONFLICT
        ..file1length = 2
        ..file1offset = 1
        ..file2length = 2
        ..file2offset = 2;

      hunks.add(s2);
      hunks.add(s1);

      hunks.sort();

      expect(hunks[0], equals(s2));
      expect(hunks[1], equals(s1));
    });

    test('sort file1offset equal, s1 equal s2', () {
      List<Diff3Set> hunks = new List<Diff3Set>();
      Diff3Set s1 = new Diff3Set();
      s1..side = Side.LEFT
        ..file1length = 1
        ..file1offset = 1
        ..file2length = 1
        ..file2offset = 1;

      Diff3Set s2 = new Diff3Set();
      s2..side = Side.LEFT
        ..file1length = 2
        ..file1offset = 1
        ..file2length = 2
        ..file2offset = 2;

      hunks.add(s2);
      hunks.add(s1);

      hunks.sort();

      expect(hunks[0], equals(s2));
      expect(hunks[1], equals(s1));
    });

    test('sort file1offset equal, sort multiple by Side', () {
      List<Diff3Set> hunks = new List<Diff3Set>();
      Diff3Set s1 = new Diff3Set();
      s1..side = Side.CONFLICT
        ..file1length = 1
        ..file1offset = 1
        ..file2length = 1
        ..file2offset = 1;

      Diff3Set s2 = new Diff3Set();
      s2..side = Side.OLD
        ..file1length = 2
        ..file1offset = 1
        ..file2length = 2
        ..file2offset = 2;

      Diff3Set s3 = new Diff3Set();
      s3..side = Side.RIGHT
        ..file1length = 2
        ..file1offset = 1
        ..file2length = 2
        ..file2offset = 2;


      hunks.add(s2);
      hunks.add(s3);
      hunks.add(s1);

      hunks.sort();

      expect(hunks[0], equals(s1));
      expect(hunks[1], equals(s2));
      expect(hunks[2], equals(s3));
    });
  });
}

void main() {
  defineTests();
}
