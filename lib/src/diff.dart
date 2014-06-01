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
