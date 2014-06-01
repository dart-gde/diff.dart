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
  throw new UnimplementedError();
}

// TODO(adam): make private
void flushOk(List<String> okLines, List<IMergeResultBlock> result) {
  throw new UnimplementedError();
}

// TODO(adam): make closure
//bool isTrueConflict(patch3Set rec, string[] a, string[] b)  {
//
//}

List<IMergeResultBlock> diff3_merge(List<String> a, List<String> o, List<String>
    b, bool excludeFalseConflicts) {
  throw new UnimplementedError();
}
