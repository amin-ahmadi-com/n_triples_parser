import 'package:n_triples_parser/n_triples_types.dart';
import 'package:test/test.dart';

void main() {
  test("toString", () {
    final term = NTripleTerm(
      termType: NTripleTermType.iri,
      value: "https://amin-ahmadi.com",
      languageTag: "en",
      dataType: "S",
    );

    expect(
      term.toString(),
      "NTripleTermType.iri : https://amin-ahmadi.com @en ^^S",
    );
  });

  test("hashDigest", () {
    final term = NTripleTerm(
      termType: NTripleTermType.iri,
      value: "https://amin-ahmadi.com",
      languageTag: "en",
      dataType: "S",
    );

    final stopwatch = Stopwatch()..start();
    final result = term.hashDigest;
    print(
      'hashDigest took ${stopwatch.elapsed.inMicroseconds} microseconds.',
    );

    // To compare, hashDigest result was generated on https://emn178.github.io/online-tools/sha256.html
    // Using input string: NTripleTermType.iri : https://amin-ahmadi.com @en ^^S
    expect(
      result,
      "7bb183a274a0b2bed35406b316a6dbda181191ae6de740b9a7be1d1ebe00da75",
    );
  });
}
