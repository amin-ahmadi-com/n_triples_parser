import 'package:test/test.dart';
import 'package:n_triples_parser/utils.dart' as utils;

void main() {
  test("removeLastCharacters", () {
    expect(utils.removeLastCharacters("", 1), "");
    expect(utils.removeLastCharacters(" ", 2), "");
    expect(utils.removeLastCharacters("ABC", 1), "AB");
    expect(utils.removeLastCharacters(" AB", 1), " A");
    expect(utils.removeLastCharacters(" ABCDE", 3), " AB");
  });

  test("removeFirstCharacters", () {
    expect(utils.removeFirstCharacters("", 1), "");
    expect(utils.removeFirstCharacters(" ", 2), "");
    expect(utils.removeFirstCharacters("ABC", 1), "BC");
    expect(utils.removeFirstCharacters(" AB", 1), "AB");
    expect(utils.removeFirstCharacters(" ABCDE", 3), "CDE");
  });
}
