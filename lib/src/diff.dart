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
  /* Text diff algorithm following Hunt and McIlroy 1976.
   * J. W. Hunt and M. D. McIlroy, An algorithm for differential file
   * comparison, Bell Telephone Laboratories CSTR #41 (1976)
   * http://www.cs.dartmouth.edu/~doug/
   *
   * Expects two arrays of strings.
   */

  Map<String, List<int>> equivalenceClasses = new Map<String, List<int>>();
  List<int> file2indices;
  Map<int, CandidateThing> candidates = new Map<int, CandidateThing>();

  candidates[0] = new CandidateThing()
      ..file1index = -1
      ..file2index = -1
      ..chain = null;

  for (int j = 0; j < file2.length; j++) {
    String line = file2[j];
    if (equivalenceClasses.containsKey(line)) {
      equivalenceClasses[line].add(j);
    } else {
      equivalenceClasses[line] = <int>[j];
    }
  }

  for (int i = 0; i < file1.length; i++) {
    String line = file1[i];
    if (equivalenceClasses.containsKey(line)) {
      file2indices = equivalenceClasses[line];
    } else {
      file2indices = new List<int>();
    }

    int r = 0;
    int s = 0;
    CandidateThing c = candidates[0];

    for (int jX = 0; jX < file2indices.length; jX++) {
      int j = file2indices[jX];

      for (s = r; s < candidates.length; s++) {
        if ((candidates[s].file2index < j) && ((s == candidates.length - 1) ||
            (candidates[s + 1].file2index > j))) {
          break;
        }
      }

      if (s < candidates.length) {
        CandidateThing newCandidate = new CandidateThing()
            ..file1index = i
            ..file2index = j
            ..chain = candidates[s];

        candidates[r] = c;
        r = s + 1;
        c = newCandidate;
        if (r == candidates.length) {
          break; // no point in examining further (j)s
        }
      }
    }

    candidates[r] = c;
  }

  // At this point, we know the LCS: it's in the reverse of the
  // linked-list through .chain of
  // candidates[candidates.length - 1].

  return candidates[candidates.length - 1];
}

// TODO(adam): make this a closure and do not pass common;
//void processCommon(ref commonOrDifferentThing common, List<commonOrDifferentThing> result) {
//  throw new UnimplementedError();
//}

List<commonOrDifferentThing> diff_comm(List<String> file1, List<String> file2) {
  // We apply the LCS to build a "comm"-style picture of the
  // differences between file1 and file2.

  List<commonOrDifferentThing> result = new List<commonOrDifferentThing>();

  int tail1 = file1.length;
  int tail2 = file2.length;

  commonOrDifferentThing common = new commonOrDifferentThing()..common =
      new List<String>();

  void processCommon() {
    if (common.common.length > 0) {
      common.common = common.common.reversed.toList();
      result.add(common);
      common = new commonOrDifferentThing()..common = new List<String>();
    }
  }

  for (CandidateThing candidate = longest_common_subsequence(file1, file2);
      candidate != null; candidate = candidate.chain) {
    commonOrDifferentThing different = new commonOrDifferentThing()
        ..file1 = new List<String>()
        ..file2 = new List<String>();

    while (--tail1 > candidate.file1index) {
      different.file1.add(file1[tail1]);
    }

    while (--tail2 > candidate.file2index) {
      different.file2.add(file2[tail2]);
    }

    if (different.file1.length > 0 || different.file2.length > 0) {
      processCommon();
      different.file1 = different.file1.reversed.toList();
      different.file2 = different.file2.reversed.toList();
      result.add(different);
    }

    if (tail1 >= 0) {
      common.common.add(file1[tail1]);
    }
  }

  processCommon();

  return result.reversed.toList();
}

List<patchResult> diff_patch(List<String> file1, List<String> file2) {
  // We apply the LCD to build a JSON representation of a
  // diff(1)-style patch.

  List<patchResult> result = new List<patchResult>();
  int tail1 = file1.length;
  int tail2 = file2.length;

  for (CandidateThing candidate = longest_common_subsequence(file1, file2);
      candidate != null; candidate = candidate.chain) {
    int mismatchLength1 = tail1 - candidate.file1index - 1;
    int mismatchLength2 = tail2 - candidate.file2index - 1;
    tail1 = candidate.file1index;
    tail2 = candidate.file2index;

    if (mismatchLength1 > 0 || mismatchLength2 > 0) {
      patchResult thisResult = new patchResult();
      thisResult
          ..file1 = new patchDescriptionThing.fromFile(file1,
              candidate.file1index + 1, mismatchLength1)
          ..file2 = new patchDescriptionThing.fromFile(file2,
              candidate.file2index + 1, mismatchLength2);

      result.add(thisResult);
    }
  }


  return result.reversed.toList();
}

List<patchResult> strip_patch(List<patchResult> patch) {
  // Takes the output of Diff.diff_patch(), and removes
  // information from it. It can still be used by patch(),
  // below, but can no longer be inverted.

  List<patchResult> newpatch = new List<patchResult>();
  for (int i = 0; i < patch.length; i++) {
    patchResult chunk = patch[i];
    patchResult patchResultNewPatch = new patchResult();
    patchResultNewPatch.file1 = new patchDescriptionThing()
    ..Offset = chunk.file1.Offset
    ..Length = chunk.file1.Length;

    patchResultNewPatch.file2 = new patchDescriptionThing()
    ..Chunk = chunk.file2.Chunk;

    newpatch.add(patchResultNewPatch);
  }

  return newpatch;
}

void invert_patch(List<patchResult> patch) {
  // Takes the output of Diff.diff_patch(), and inverts the
  // sense of it, so that it can be applied to file2 to give
  // file1 rather than the other way around.
  for (int i = 0; i < patch.length; i++) {
    patchResult chunk = patch[i];
    patchDescriptionThing tmp = chunk.file1;
    chunk.file1 = chunk.file2;
    chunk.file2 = tmp;
  }
}

// TODO(adam): make this a closure
//void copyCommon(int targetOffset, ref int commonOffset, string[] file, List<string> result)  {
//
//}

List<String> patch(List<String> file, List<patchResult> patch) {
  // Applies a patch to a file.
  //
  // Given file1 and file2, Diff.patch(file1, Diff.diff_patch(file1, file2)) should give file2.

  List<String> result = new List<String>();
  int commonOffset = 0;

  void copyCommon(int targetOffset) {
    while (commonOffset < targetOffset) {
      result.add(file[commonOffset]);
      commonOffset++;
    }
  }

  for (int chunkIndex = 0; chunkIndex < patch.length; chunkIndex++) {
    patchResult chunk = patch[chunkIndex];
    copyCommon(chunk.file1.Offset);

    for (int lineIndex = 0; lineIndex < chunk.file2.Chunk.length; lineIndex++) {
      result.add(chunk.file2.Chunk[lineIndex]);
    }

    commonOffset += chunk.file1.Length;
  }

  copyCommon(file.length);

  return result;
}

List<String> diff_merge_keepall(List<String> file1, List<String> file2) {
  throw new UnimplementedError();
}

List<diffSet> diff_indices(List<String> file1, List<String> file2) {
  // We apply the LCS to give a simple representation of the
  // offsets and lengths of mismatched chunks in the input
  // files. This is used by diff3_merge_indices below.

  List<diffSet> result = new List<diffSet>();
  int tail1 = file1.length;
  int tail2 = file2.length;

  for (CandidateThing candidate = longest_common_subsequence(file1, file2);
      candidate != null; candidate = candidate.chain) {
    int mismatchLength1 = tail1 - candidate.file1index - 1;
    int mismatchLength2 = tail2 - candidate.file2index - 1;
    tail1 = candidate.file1index;
    tail2 = candidate.file2index;

    if (mismatchLength1 > 0 || mismatchLength2 > 0) {
      diffSet diffSetResult = new diffSet();
      diffSetResult
          ..file1 = (new chunkReference()
              ..offset = tail1 + 1
              ..length = mismatchLength1)
          ..file2 = (new chunkReference()
              ..offset = tail2 + 1
              ..length = mismatchLength2);
      result.add(diffSetResult);
    }
  }

  return result.reversed.toList();
}

// TODO(adam): make private
void addHunk(diffSet h, Side side, List<diff3Set> hunks) {
  diff3Set diff3SetHunk = new diff3Set();
  diff3SetHunk
      ..side = side
      ..file1offset = h.file1.offset
      ..file1length = h.file1.length
      ..file2offset = h.file2.offset
      ..file2length = h.file2.length;
  hunks.add(diff3SetHunk);
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

      int aLhs = regions[Side.Left].file1RegionStart + (regionLhs -
          regions[Side.Left].file2RegionStart);
      int aRhs = regions[Side.Left].file1RegionEnd + (regionRhs -
          regions[Side.Left].file2RegionEnd);
      int bLhs = regions[Side.Right].file1RegionStart + (regionLhs -
          regions[Side.Right].file2RegionStart);
      int bRhs = regions[Side.Right].file1RegionEnd + (regionRhs -
          regions[Side.Right].file2RegionEnd);

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
