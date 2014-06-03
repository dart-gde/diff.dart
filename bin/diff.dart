import "dart:io";

import "package:diff/diff.dart";

void main(List<String> args) {
  if (args.length != 3) {
    print("diff.dart [ours] [base] [theirs]");
    return;
  }

  String filename1 = args[0]; // ours
  String filename2 = args[1]; // base
  String filename3 = args[2]; // theirs

  File file1 = new File(filename1);
  String file1Contents = file1.readAsStringSync();

  File file2 = new File(filename2);
  String file2Contents = file2.readAsStringSync();

  File file3 = new File(filename3);
  String file3Contents = file3.readAsStringSync();

  Diff3DigResult diff3DigResult = diff3Dig(file1Contents, file2Contents,
      file3Contents);

  if (diff3DigResult.Conflict) {
    print("diff3_dig: $filename1, $filename2, $filename3");
    print(diff3DigResult.Text.join("\n"));
  } else {
    print("No conflicts found with $filename1, $filename2, $filename3");
  }
}
