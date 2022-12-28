import 'package:test/test.dart';
import 'package:n_triples_parser/utils.dart' as utils;

void main() {
  test("removeLastCharacter", () {
    expect(utils.removeLastCharacter(""), "");
    expect(utils.removeLastCharacter(" "), "");
    expect(utils.removeLastCharacter("ABC"), "AB");
    expect(utils.removeLastCharacter(" AB"), " A");
  });
}
