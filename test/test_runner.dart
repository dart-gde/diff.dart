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

  test('diff3Set sort file1offset not equal', () {
    List<diff3Set> hunks = new List<diff3Set>();
    diff3Set s1 = new diff3Set();
    s1..side = Side.Conflict
      ..file1length = 1
      ..file1offset = 1
      ..file2length = 1
      ..file2offset = 1;

    diff3Set s2 = new diff3Set();
    s2..side = Side.Left
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

  test('diff3Set sort file1offset equal, s2 greater then s1', () {
    List<diff3Set> hunks = new List<diff3Set>();
    diff3Set s1 = new diff3Set();
    s1..side = Side.Conflict
      ..file1length = 1
      ..file1offset = 1
      ..file2length = 1
      ..file2offset = 1;

    diff3Set s2 = new diff3Set();
    s2..side = Side.Left
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

  test('diff3Set sort file1offset equal, s1 greater then s2', () {
    List<diff3Set> hunks = new List<diff3Set>();
    diff3Set s1 = new diff3Set();
    s1..side = Side.Left
      ..file1length = 1
      ..file1offset = 1
      ..file2length = 1
      ..file2offset = 1;

    diff3Set s2 = new diff3Set();
    s2..side = Side.Conflict
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

  test('diff3Set sort file1offset equal, s1 equal s2', () {
    List<diff3Set> hunks = new List<diff3Set>();
    diff3Set s1 = new diff3Set();
    s1..side = Side.Left
      ..file1length = 1
      ..file1offset = 1
      ..file2length = 1
      ..file2offset = 1;

    diff3Set s2 = new diff3Set();
    s2..side = Side.Left
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

  test('diff3Set sort file1offset equal, sort multiple by Side', () {
    List<diff3Set> hunks = new List<diff3Set>();
    diff3Set s1 = new diff3Set();
    s1..side = Side.Conflict
      ..file1length = 1
      ..file1offset = 1
      ..file2length = 1
      ..file2offset = 1;

    diff3Set s2 = new diff3Set();
    s2..side = Side.Old
      ..file1length = 2
      ..file1offset = 1
      ..file2length = 2
      ..file2offset = 2;

    diff3Set s3 = new diff3Set();
    s3..side = Side.Right
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
}

void main() {
  tests();
}