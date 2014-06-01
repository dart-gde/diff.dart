part of diff;

//
// Arbitrarily-named in-between objects
//

class CandidateThing {
  int file1index;
  int file2index;
  CandidateThing chain;
}

class commonOrDifferentThing {
  List<String> common;
  List<String> file1;
  List<String> file2;
}

class patchDescriptionThing {
  patchDescriptionThing() {}

  patchDescriptionThing.fromFile(List<String> file, int offset, int length) {
    Offset = offset;
    Length = length;
    Chunk = new List<String>.from(file.getRange(offset, offset + length).toList(
        ));
  }

  int Offset;
  int Length;
  List<String> Chunk;
}

class patchResult {
  patchDescriptionThing file1;
  patchDescriptionThing file2;
}

class chunkReference {
  int offset;
  int length;
}

class diffSet {
  chunkReference file1;
  chunkReference file2;
}

class Side<int> extends Enum<int> implements Comparable<Side<int>> {
  const Side(int val) : super(val);
  static const Side Conflict = const Side(-1);
  static const Side Left = const Side(0);
  static const Side Old = const Side(1);
  static const Side Right = const Side(2);

  @override
  /*int*/ compareTo(Side<int> other) {
    // TODO(adam): figure out why dart editor thinks int is a warning?
    return value.compareTo(other.value);
  }
}

class diff3Set implements Comparable<diff3Set> {
  Side side;
  int file1offset;
  int file1length;
  int file2offset;
  int file2length;

  int compareTo(diff3Set other) {
    if (file1offset != other.file1offset) {
      return file1offset.compareTo(other.file1offset);
    } else {
      return side.compareTo(other.side);
    }
  }
}

class patch3Set {
  Side side;
  int offset;
  int length;
  int conflictOldOffset;
  int conflictOldLength;
  int conflictRightOffset;
  int conflictRightLength;
}

class conflictRegion {
  int file1RegionStart;
  int file1RegionEnd;
  int file2RegionStart;
  int file2RegionEnd;
}

//
// Merge Result Objects
//

abstract class IMergeResultBlock {
  // amusingly, I can't figure out anything they have in common.
}

class MergeOKResultBlock implements IMergeResultBlock {
  List<String> ContentLines;
}

class MergeConflictResultBlock implements IMergeResultBlock {
  List<String> LeftLines;
  int LeftIndex;
  List<String> OldLines;
  int OldIndex;
  List<String> RightLines;
  int RightIndex;
}

//
// Methods
//

CandidateThing longest_common_subsequence(List<String> file1, List<String>
    file2) {
  throw new UnimplementedError();
}

// TODO(adam): make this a closure and do not pass common;
//void processCommon(ref commonOrDifferentThing common, List<commonOrDifferentThing> result) {
//  throw new UnimplementedError();
//}

List<commonOrDifferentThing> diff_comm(List<String> file1, List<String> file2) {
  throw new UnimplementedError();
}

List<patchResult> diff_patch(List<String> file1, List<String> file2) {
  throw new UnimplementedError();
}

List<patchResult> strip_patch(List<patchResult> patch) {
  throw new UnimplementedError();
}

void invert_patch(List<patchResult> patch) {
  throw new UnimplementedError();
}

// TODO(adam): make this a closure
//void copyCommon(int targetOffset, ref int commonOffset, string[] file, List<string> result)  {
//
//}

List<String> patch(List<String> file, List<patchResult> patch) {
  throw new UnimplementedError();
}

List<String> diff_merge_keepall(List<String> file1, List<String> file2) {
  throw new UnimplementedError();
}

List<diffSet> diff_indices(List<String> file1, List<String> file2) {
  throw new UnimplementedError();
}

// TODO(adam): make private
void addHunk(diffSet h, Side side, List<diff3Set> hunks) {
  throw new UnimplementedError();
}

// TODO(adam): make this a closure
//void copyCommon2(int targetOffset, ref int commonOffset, List<patch3Set> result) {
//
//}

List<patch3Set> diff3_merge_indices(List<String> a, List<String> o, List<String>
    b) {
  // Given three files, A, O, and B, where both A and B are
  // independently derived from O, returns a fairly complicated
  // internal representation of merge decisions it's taken. The
  // interested reader may wish to consult
  //
  // Sanjeev Khanna, Keshav Kunal, and Benjamin C. Pierce. "A
  // Formal Investigation of Diff3." In Arvind and Prasad,
  // editors, Foundations of Software Technology and Theoretical
  // Computer Science (FSTTCS), December 2007.
  //
  // (http://www.cis.upenn.edu/~bcpierce/papers/diff3-short.pdf)

  List<diffSet> m1 = diff_indices(o, a);
  List<diffSet> m2 = diff_indices(o, b);

  List<diff3Set> hunks = new List<diff3Set>();

  for (int i = 0; i < m1.length; i++) {
    addHunk(m1[i], Side.Left, hunks);
  }

  for (int i = 0; i < m2.length; i++) {
    addHunk(m2[i], Side.Right, hunks);
  }

  hunks.sort();

  List<patch3Set> result = new List<patch3Set>();
  int commonOffset = 0;

  void copyCommon(int targetOffset) {
    if (targetOffset > commonOffset) {
      patch3Set patch3SetResult = new patch3Set();
      patch3SetResult
        ..side = Side.Old
        ..offset = commonOffset
        ..length = targetOffset - commonOffset;
      result.add(patch3SetResult);
    }
  }

  for (int hunkIndex = 0; hunkIndex < hunks.length; hunkIndex++) {
    int firstHunkIndex = hunkIndex;
    diff3Set hunk = hunks[hunkIndex];
    int regionLhs = hunk.file1offset;
    int regionRhs = regionLhs + hunk.file1length;

    while (hunkIndex < hunks.length - 1) {
      diff3Set maybeOverlapping = hunks[hunkIndex + 1];
      int maybeLhs = maybeOverlapping.file1offset;
      if (maybeLhs > regionRhs) {
        break;
      }

      regionRhs = Math.max(regionRhs, maybeLhs + maybeOverlapping.file1length);
      hunkIndex++;
    }

    copyCommon(regionLhs);
    if (firstHunkIndex == hunkIndex) {
      // The "overlap" was only one hunk long, meaning that
      // there's no conflict here. Either a and o were the
      // same, or b and o were the same.
      if (hunk.file2length > 0) {
        patch3Set patch3SetResult = new patch3Set();
        patch3SetResult
          ..side = hunk.side
          ..offset = hunk.file2offset
          ..length = hunk.file2length;
        result.add(patch3SetResult);
      }
    } else {
      // A proper conflict. Determine the extents of the
      // regions involved from a, o and b. Effectively merge
      // all the hunks on the left into one giant hunk, and
      // do the same for the right; then, correct for skew
      // in the regions of o that each side changed, and
      // report appropriate spans for the three sides.
      Map<Side, conflictRegion> regions = new Map<Side, conflictRegion>();
      regions[Side.Left] = new conflictRegion()
          ..file1RegionStart = a.length
          ..file1RegionEnd = -1
          ..file2RegionStart = o.length
          ..file2RegionEnd = -1;

      regions[Side.Right] = new conflictRegion()
          ..file1RegionStart = b.length
          ..file1RegionEnd = -1
          ..file2RegionStart = o.length
          ..file2RegionEnd = -1;

      for (int i = firstHunkIndex; i <= hunkIndex; i++) {
        hunk = hunks[i];
        Side side = hunk.side;
        conflictRegion r = regions[side];
        int oLhs = hunk.file1offset;
        int oRhs = oLhs + hunk.file1length;
        int abLhs = hunk.file2offset;
        int abRhs = abLhs + hunk.file2length;
        r.file1RegionStart = Math.min(abLhs, r.file1RegionStart);
        r.file1RegionEnd = Math.max(abRhs, r.file1RegionEnd);
        r.file2RegionStart = Math.min(oLhs, r.file2RegionStart);
        r.file2RegionEnd = Math.max(oRhs, r.file2RegionEnd);
      }

      int aLhs = regions[Side.Left].file1RegionStart +
          (regionLhs - regions[Side.Left].file2RegionStart);
      int aRhs = regions[Side.Left].file1RegionEnd +
          (regionRhs - regions[Side.Left].file2RegionEnd);
      int bLhs = regions[Side.Right].file1RegionStart +
          (regionLhs - regions[Side.Right].file2RegionStart);
      int bRhs = regions[Side.Right].file1RegionEnd +
          (regionRhs - regions[Side.Right].file2RegionEnd);

      patch3Set patch3SetResult = new patch3Set();
      patch3SetResult
        ..side = Side.Conflict
        ..offset = aLhs
        ..length = aRhs - aLhs
        ..conflictOldOffset = regionLhs
        ..conflictOldLength = regionRhs - regionLhs
        ..conflictRightOffset = bLhs
        ..conflictRightLength = bRhs - bLhs;
      result.add(patch3SetResult);
    }

    commonOffset = regionRhs;
  }

  copyCommon(o.length);
  return result;
}

// TODO(adam): make private
void flushOk(List<String> okLines, List<IMergeResultBlock> result) {
  if (okLines.length > 0) {
    MergeOKResultBlock okResult = new MergeOKResultBlock();
    okResult.ContentLines = okLines.toList();
    result.add(okResult);
  }

  okLines.clear();
}

// TODO(adam): make private
bool isTrueConflict(patch3Set rec, List<String> a, List<String> b) {
  if (rec.length != rec.conflictRightLength) {
    return true;
  }

  int aoff = rec.offset;
  int boff = rec.conflictRightOffset;

  for (int j = 0; j < rec.length; j++) {
    if (a[j + aoff] != b[j + boff]) {
      return true;
    }
  }

  return false;
}

List<IMergeResultBlock> diff3_merge(List<String> a, List<String> o, List<String>
    b, bool excludeFalseConflicts) {
  // Applies the output of Diff.diff3_merge_indices to actually
  // construct the merged file; the returned result alternates
  // between "ok" and "conflict" blocks.

  List<IMergeResultBlock> result = new List<IMergeResultBlock>();
  Map<Side, List<String>> files = new Map<Side, List<String>>();
  files[Side.Left] = a;
  files[Side.Old] = o;
  files[Side.Right] = b;

  List<patch3Set> indices = diff3_merge_indices(a, o, b);
  List<String> okLines = new List<String>();

  for (int i = 0; i < indices.length; i++) {
    patch3Set x = indices[i];
    Side side = x.side;

    if (side == Side.Conflict) {
      if (excludeFalseConflicts && !isTrueConflict(x, a, b)) {
        okLines.addAll(files[0].getRange(x.offset, x.offset + x.length).toList()
            );
      } else {
        flushOk(okLines, result);
        MergeConflictResultBlock mergeConflictResultBlock =
            new MergeConflictResultBlock();
        mergeConflictResultBlock
            ..LeftLines = a.getRange(x.offset, x.offset + x.length).toList()
            ..LeftIndex = x.offset
            ..OldLines = o.getRange(x.conflictOldOffset, x.conflictOldOffset +
                x.conflictOldLength).toList()
            ..OldIndex = x.conflictOldOffset
            ..RightLines = b.getRange(x.conflictRightOffset,
                x.conflictRightOffset + x.conflictRightLength).toList()
            ..RightIndex = x.offset;
        result.add(mergeConflictResultBlock);
      }
    } else {
      okLines.addAll(files[side].getRange(x.offset, x.offset + x.length).toList(
          ));
    }
  }

  flushOk(okLines, result);
  return result;
}
