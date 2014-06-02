library test_runner;

import "src/side_enum_test.dart" as side_enum_test;
import "src/diff3_set_test.dart" as diff3_set_test;
import "src/diff3_dig_test.dart" as diff3_dig_test;
import "src/diff3_merge_test.dart" as diff3_merge_test;

void main() {
  side_enum_test.main();
  diff3_set_test.main();
  diff3_dig_test.main();
  diff3_merge_test.main();
}
