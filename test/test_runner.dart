library test_runner;

import "src/side_enum_test.dart" as side_enum_test;
import "src/diff3_set_test.dart" as diff3_set_test;

void main() {
  side_enum_test.main();
  diff3_set_test.main();
}
