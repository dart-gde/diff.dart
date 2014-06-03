part of diff;

//
// Arbitrarily-named in-between objects
//

class CandidateThing {
  int file1index;
  int file2index;
  CandidateThing chain;
}

class CommonOrDifferentThing {
  List<String> common;
  List<String> file1;
  List<String> file2;
}

class PatchDescriptionThing {
  PatchDescriptionThing() {}

  PatchDescriptionThing.fromFile(List<String> file, this.offset, this.length) {
    chunk = new List<String>.from(file.getRange(offset, offset + length).toList(
        ));
  }

  int offset;
  int length;
  List<String> chunk;
}

class PatchResult {
  PatchDescriptionThing file1;
  PatchDescriptionThing file2;
}

class ChunkReference {
  int offset;
  int length;
}

class DiffSet {
  ChunkReference file1;
  ChunkReference file2;
}

class Side<int> extends Enum<int> implements Comparable<Side<int>> {
  const Side(int val) : super(val);
  static const Side CONFLICT = const Side(-1);
  static const Side LEFT = const Side(0);
  static const Side OLD = const Side(1);
  static const Side RIGHT = const Side(2);

  @override
  /*int*/ compareTo(Side<int> other) {
    // TODO(adam): figure out why dart editor thinks int is a warning?
    return value.compareTo(other.value);
  }
}

class Diff3Set implements Comparable<Diff3Set> {
  Side side;
  int file1offset;
  int file1length;
  int file2offset;
  int file2length;

  int compareTo(Diff3Set other) {
    if (file1offset != other.file1offset) {
      return file1offset.compareTo(other.file1offset);
    } else {
      return side.compareTo(other.side);
    }
  }
}

class Patch3Set {
  Side side;
  int offset;
  int length;
  int conflictOldOffset;
  int conflictOldLength;
  int conflictRightOffset;
  int conflictRightLength;
}

class ConflictRegion {
  int file1RegionStart;
  int file1RegionEnd;
  int file2RegionStart;
  int file2RegionEnd;
}


class Diff3DigResult {
  bool conflict;
  List<String> text;
}

//
// Merge Result Objects
//

abstract class MergeResultBlock {
  // amusingly, I can't figure out anything they have in common.
}

class MergeOKResultBlock implements MergeResultBlock {
  List<String> contentLines;
}

class MergeConflictResultBlock implements MergeResultBlock {
  List<String> leftLines;
  int leftIndex;
  List<String> oldLines;
  int oldIndex;
  List<String> rightLines;
  int rightIndex;
}

//
// Methods
//

CandidateThing longestCommonSubsequence(List<String> file1, List<String>
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

List<CommonOrDifferentThing> diffComm(List<String> file1, List<String> file2) {
  // We apply the LCS to build a "comm"-style picture of the
  // differences between file1 and file2.

  List<CommonOrDifferentThing> result = new List<CommonOrDifferentThing>();

  int tail1 = file1.length;
  int tail2 = file2.length;

  CommonOrDifferentThing common = new CommonOrDifferentThing();
  common.common = new List<String>();

  void processCommon() {
    if (common.common.length > 0) {
      common.common = common.common.reversed.toList();
      result.add(common);
      common = new CommonOrDifferentThing();
      common.common = new List<String>();
    }
  }

  for (CandidateThing candidate = longestCommonSubsequence(file1, file2);
      candidate != null; candidate = candidate.chain) {
    CommonOrDifferentThing different = new CommonOrDifferentThing()
        ..file1 = new List<String>()
        ..file2 = new List<String>()
        ..common = new List<String>();

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

List<PatchResult> diffPatch(List<String> file1, List<String> file2) {
  // We apply the LCD to build a JSON representation of a
  // diff(1)-style patch.

  List<PatchResult> result = new List<PatchResult>();
  int tail1 = file1.length;
  int tail2 = file2.length;

  for (CandidateThing candidate = longestCommonSubsequence(file1, file2);
      candidate != null; candidate = candidate.chain) {
    int mismatchLength1 = tail1 - candidate.file1index - 1;
    int mismatchLength2 = tail2 - candidate.file2index - 1;
    tail1 = candidate.file1index;
    tail2 = candidate.file2index;

    if (mismatchLength1 > 0 || mismatchLength2 > 0) {
      PatchResult thisResult = new PatchResult();
      thisResult
          ..file1 = new PatchDescriptionThing.fromFile(file1,
              candidate.file1index + 1, mismatchLength1)
          ..file2 = new PatchDescriptionThing.fromFile(file2,
              candidate.file2index + 1, mismatchLength2);

      result.add(thisResult);
    }
  }


  return result.reversed.toList();
}

List<PatchResult> stripPatch(List<PatchResult> patch) {
  // Takes the output of Diff.diff_patch(), and removes
  // information from it. It can still be used by patch(),
  // below, but can no longer be inverted.

  List<PatchResult> newpatch = new List<PatchResult>();
  for (int i = 0; i < patch.length; i++) {
    PatchResult chunk = patch[i];
    PatchResult patchResultNewPatch = new PatchResult();
    patchResultNewPatch.file1 = new PatchDescriptionThing()
        ..offset = chunk.file1.offset
        ..length = chunk.file1.length;

    patchResultNewPatch.file2 = new PatchDescriptionThing()..chunk =
        chunk.file2.chunk;

    newpatch.add(patchResultNewPatch);
  }

  return newpatch;
}

void invertPatch(List<PatchResult> patch) {
  // Takes the output of Diff.diff_patch(), and inverts the
  // sense of it, so that it can be applied to file2 to give
  // file1 rather than the other way around.
  for (int i = 0; i < patch.length; i++) {
    PatchResult chunk = patch[i];
    PatchDescriptionThing tmp = chunk.file1;
    chunk.file1 = chunk.file2;
    chunk.file2 = tmp;
  }
}

List<String> patch(List<String> file, List<PatchResult> patch) {
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
    PatchResult chunk = patch[chunkIndex];
    copyCommon(chunk.file1.offset);

    for (int lineIndex = 0; lineIndex < chunk.file2.chunk.length; lineIndex++) {
      result.add(chunk.file2.chunk[lineIndex]);
    }

    commonOffset += chunk.file1.length;
  }

  copyCommon(file.length);

  return result;
}

List<String> diffMergeKeepall(List<String> file1, List<String> file2) {
  // Non-destructively merges two files.
  //
  // This is NOT a three-way merge - content will often be DUPLICATED by this process, eg
  // when starting from the same file some content was moved around on one of the copies.
  //
  // To handle typical "common ancestor" situations and avoid incorrect duplication of
  // content, use diff3_merge instead.
  //
  // This method's behaviour is similar to gnu diff's "if-then-else" (-D) format, but
  // without the if/then/else lines!
  //

  List<String> result = new List<String>();
  int file1CompletedToOffset = 0;
  List<PatchResult> diffPatches = diffPatch(file1, file2);

  for (int chunkIndex = 0; chunkIndex < diffPatches.length; chunkIndex++) {
    PatchResult chunk = diffPatches[chunkIndex];
    if (chunk.file2.length > 0) {
      //copy any not-yet-copied portion of file1 to the end of this patch entry
      result.addAll(file1.getRange(file1CompletedToOffset, chunk.file1.offset +
          chunk.file1.length).toList());
      file1CompletedToOffset = chunk.file1.offset + chunk.file1.length;

      // copy the file2 portion of this patch entry
      result.addAll(chunk.file2.chunk);
    }
  }

  //copy any not-yet-copied portion of file1 to the end of the file
  result.addAll(file1.getRange(file1CompletedToOffset, file1.length).toList());

  return result;
}

List<DiffSet> diffIndices(List<String> file1, List<String> file2) {
  // We apply the LCS to give a simple representation of the
  // offsets and lengths of mismatched chunks in the input
  // files. This is used by diff3_merge_indices below.

  List<DiffSet> result = new List<DiffSet>();
  int tail1 = file1.length;
  int tail2 = file2.length;

  for (CandidateThing candidate = longestCommonSubsequence(file1, file2);
      candidate != null; candidate = candidate.chain) {
    int mismatchLength1 = tail1 - candidate.file1index - 1;
    int mismatchLength2 = tail2 - candidate.file2index - 1;
    tail1 = candidate.file1index;
    tail2 = candidate.file2index;

    if (mismatchLength1 > 0 || mismatchLength2 > 0) {
      DiffSet diffSetResult = new DiffSet();
      diffSetResult
          ..file1 = (new ChunkReference()
              ..offset = tail1 + 1
              ..length = mismatchLength1)
          ..file2 = (new ChunkReference()
              ..offset = tail2 + 1
              ..length = mismatchLength2);
      result.add(diffSetResult);
    }
  }

  return result.reversed.toList();
}

// TODO(adam): make private
void _addHunk(DiffSet h, Side side, List<Diff3Set> hunks) {
  Diff3Set diff3SetHunk = new Diff3Set();
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

List<Patch3Set> diff3MergeIndices(List<String> a, List<String> o, List<String>
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

  List<DiffSet> m1 = diffIndices(o, a);
  List<DiffSet> m2 = diffIndices(o, b);

  List<Diff3Set> hunks = new List<Diff3Set>();

  for (int i = 0; i < m1.length; i++) {
    _addHunk(m1[i], Side.LEFT, hunks);
  }

  for (int i = 0; i < m2.length; i++) {
    _addHunk(m2[i], Side.RIGHT, hunks);
  }

  hunks.sort();

  List<Patch3Set> result = new List<Patch3Set>();
  int commonOffset = 0;

  void copyCommon(int targetOffset) {
    if (targetOffset > commonOffset) {
      Patch3Set patch3SetResult = new Patch3Set();
      patch3SetResult
          ..side = Side.OLD
          ..offset = commonOffset
          ..length = targetOffset - commonOffset;
      result.add(patch3SetResult);
    }
  }

  for (int hunkIndex = 0; hunkIndex < hunks.length; hunkIndex++) {
    int firstHunkIndex = hunkIndex;
    Diff3Set hunk = hunks[hunkIndex];
    int regionLhs = hunk.file1offset;
    int regionRhs = regionLhs + hunk.file1length;

    while (hunkIndex < hunks.length - 1) {
      Diff3Set maybeOverlapping = hunks[hunkIndex + 1];
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
        Patch3Set patch3SetResult = new Patch3Set();
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
      Map<Side, ConflictRegion> regions = new Map<Side, ConflictRegion>();
      regions[Side.LEFT] = new ConflictRegion()
          ..file1RegionStart = a.length
          ..file1RegionEnd = -1
          ..file2RegionStart = o.length
          ..file2RegionEnd = -1;

      regions[Side.RIGHT] = new ConflictRegion()
          ..file1RegionStart = b.length
          ..file1RegionEnd = -1
          ..file2RegionStart = o.length
          ..file2RegionEnd = -1;

      for (int i = firstHunkIndex; i <= hunkIndex; i++) {
        hunk = hunks[i];
        Side side = hunk.side;
        ConflictRegion r = regions[side];
        int oLhs = hunk.file1offset;
        int oRhs = oLhs + hunk.file1length;
        int abLhs = hunk.file2offset;
        int abRhs = abLhs + hunk.file2length;
        r.file1RegionStart = Math.min(abLhs, r.file1RegionStart);
        r.file1RegionEnd = Math.max(abRhs, r.file1RegionEnd);
        r.file2RegionStart = Math.min(oLhs, r.file2RegionStart);
        r.file2RegionEnd = Math.max(oRhs, r.file2RegionEnd);
      }

      int aLhs = regions[Side.LEFT].file1RegionStart + (regionLhs -
          regions[Side.LEFT].file2RegionStart);
      int aRhs = regions[Side.LEFT].file1RegionEnd + (regionRhs -
          regions[Side.LEFT].file2RegionEnd);
      int bLhs = regions[Side.RIGHT].file1RegionStart + (regionLhs -
          regions[Side.RIGHT].file2RegionStart);
      int bRhs = regions[Side.RIGHT].file1RegionEnd + (regionRhs -
          regions[Side.RIGHT].file2RegionEnd);

      Patch3Set patch3SetResult = new Patch3Set();
      patch3SetResult
          ..side = Side.CONFLICT
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

void _flushOk(List<String> okLines, List<MergeResultBlock> result) {
  if (okLines.length > 0) {
    MergeOKResultBlock okResult = new MergeOKResultBlock();
    okResult.contentLines = okLines.toList();
    result.add(okResult);
  }

  okLines.clear();
}

bool _isTrueConflict(Patch3Set rec, List<String> a, List<String> b) {
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

List<MergeResultBlock> diff3Merge(List<String> a, List<String> o, List<String>
    b, bool excludeFalseConflicts) {
  // Applies the output of Diff.diff3_merge_indices to actually
  // construct the merged file; the returned result alternates
  // between "ok" and "conflict" blocks.

  List<MergeResultBlock> result = new List<MergeResultBlock>();
  Map<Side, List<String>> files = new Map<Side, List<String>>();
  files[Side.LEFT] = a;
  files[Side.OLD] = o;
  files[Side.RIGHT] = b;

  List<Patch3Set> indices = diff3MergeIndices(a, o, b);
  List<String> okLines = new List<String>();

  for (int i = 0; i < indices.length; i++) {
    Patch3Set x = indices[i];
    Side side = x.side;

    if (side == Side.CONFLICT) {
      if (excludeFalseConflicts && !_isTrueConflict(x, a, b)) {
        okLines.addAll(files[0].getRange(x.offset, x.offset + x.length).toList()
            );
      } else {
        _flushOk(okLines, result);
        MergeConflictResultBlock mergeConflictResultBlock =
            new MergeConflictResultBlock();
        mergeConflictResultBlock
            ..leftLines = a.getRange(x.offset, x.offset + x.length).toList()
            ..leftIndex = x.offset
            ..oldLines = o.getRange(x.conflictOldOffset, x.conflictOldOffset +
                x.conflictOldLength).toList()
            ..oldIndex = x.conflictOldOffset
            ..rightLines = b.getRange(x.conflictRightOffset,
                x.conflictRightOffset + x.conflictRightLength).toList()
            ..rightIndex = x.offset;
        result.add(mergeConflictResultBlock);
      }
    } else {
      okLines.addAll(files[side].getRange(x.offset, x.offset + x.length).toList(
          ));
    }
  }

  _flushOk(okLines, result);
  return result;
}

Diff3DigResult diff3Dig(String ours, String base, String theirs) {
  List<String> a = ours.split("\n");
  List<String> b = theirs.split("\n");
  List<String> o = base.split("\n");

  List<MergeResultBlock> merger = diff3Merge(a, o, b, false);

  bool conflict = false;
  List<String> lines = new List<String>();

  for (int i = 0; i < merger.length; i++) {
    MergeResultBlock item = merger[i];

    if (item is MergeOKResultBlock) {
      lines.addAll(item.contentLines);
    } else if (item is MergeConflictResultBlock) {
      List<CommonOrDifferentThing> inners = diffComm(item.leftLines,
          item.rightLines);
      for (int j = 0; j < inners.length; j++) {
        CommonOrDifferentThing inner = inners[j];
        if (inner.common.length > 0) {
          lines.addAll(inner.common);
        } else {
          conflict = true;
          lines.add("<<<<<<<<<");
          lines.addAll(inner.file1);
          lines.add("=========");
          lines.addAll(inner.file2);
          lines.add(">>>>>>>>>");
        }
      }
    } else {
      throw new StateError("item type is not expected: ${item.runtimeType}");
    }
  }

  Diff3DigResult diff3DigResult = new Diff3DigResult();
  diff3DigResult.conflict = conflict;
  diff3DigResult.text = lines;
  return diff3DigResult;
}
