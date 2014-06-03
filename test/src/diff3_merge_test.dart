library diff3_merge_test;

import "package:unittest/unittest.dart";

import "package:diff/diff.dart";

void defineTests() {
  group('diff3_merge', () {
    test('multiline difference', () {
      // base
      List<String> o = "AA ZZ 00 M 99".split(" ");

      // ours
      List<String> a = "AA a b c ZZ new 00 a a M 99".split(" ");

      // theirs
      List<String> b = "AA a d c ZZ 11 M z z 99".split(" ");

      List<IMergeResultBlock> mergeResultBlocks = diff3Merge(a, o, b, false);

      expect(mergeResultBlocks, isNotNull);
      expect(mergeResultBlocks.length, equals(5));

      expect(mergeResultBlocks[0], new isInstanceOf<MergeOKResultBlock>());
      expect((mergeResultBlocks[0] as MergeOKResultBlock).ContentLines.length,
          equals(1));
      expect((mergeResultBlocks[0] as MergeOKResultBlock).ContentLines[0],
          equals("AA"));

      expect(mergeResultBlocks[1], new isInstanceOf<MergeConflictResultBlock>());
      expect((mergeResultBlocks[1] as MergeConflictResultBlock).LeftIndex,
          equals(1));
      expect((mergeResultBlocks[1] as MergeConflictResultBlock).LeftLines,
          equals(["a", "b", "c"]));
      expect((mergeResultBlocks[1] as MergeConflictResultBlock).RightIndex,
          equals(1));
      expect((mergeResultBlocks[1] as MergeConflictResultBlock).RightLines,
          equals(["a", "d", "c"]));
      expect((mergeResultBlocks[1] as MergeConflictResultBlock).OldIndex,
          equals(1));
      expect((mergeResultBlocks[1] as MergeConflictResultBlock).OldLines,
          isEmpty);

      expect(mergeResultBlocks[2], new isInstanceOf<MergeOKResultBlock>());
      expect((mergeResultBlocks[2] as MergeOKResultBlock).ContentLines.length,
          equals(1));
      expect((mergeResultBlocks[2] as MergeOKResultBlock).ContentLines[0],
          equals("ZZ"));

      expect(mergeResultBlocks[3], new isInstanceOf<MergeConflictResultBlock>());
      expect((mergeResultBlocks[3] as MergeConflictResultBlock).RightIndex,
          equals(5));
      expect((mergeResultBlocks[3] as MergeConflictResultBlock).RightLines,
          equals(["11"]));
      expect((mergeResultBlocks[3] as MergeConflictResultBlock).LeftIndex,
          equals(5));
      expect((mergeResultBlocks[3] as MergeConflictResultBlock).LeftLines,
          equals(["new", "00", "a", "a"]));
      expect((mergeResultBlocks[3] as MergeConflictResultBlock).OldIndex,
          equals(2));
      expect((mergeResultBlocks[3] as MergeConflictResultBlock).OldLines,
             equals(["00"]));

      expect(mergeResultBlocks[4], new isInstanceOf<MergeOKResultBlock>());
      expect((mergeResultBlocks[4] as MergeOKResultBlock).ContentLines.length,
          equals(4));
      expect((mergeResultBlocks[4] as MergeOKResultBlock).ContentLines,
          equals(["M", "z", "z", "99"]));
    });
  });
}

void main() {
  defineTests();
}