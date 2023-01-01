import 'package:n_triples_parser/n_triple_types.dart';
import 'package:n_triples_parser/n_triples_parser.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('IRI, IRI, IRI', () {
    const line = ""
        "<http://id.nlm.nih.gov/mesh/2022/A01.111> "
        "<http://id.nlm.nih.gov/mesh/vocab#parentTreeNumber> "
        "<http://id.nlm.nih.gov/mesh/2022/A01> "
        ".";
    final result = NTriplesParser.parseLine(line);
    expect(
        result,
        Tuple3(
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://id.nlm.nih.gov/mesh/2022/A01.111",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://id.nlm.nih.gov/mesh/vocab#parentTreeNumber",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://id.nlm.nih.gov/mesh/2022/A01",
          ),
        ));
  });

  test('IRI, IRI, Literal and Comment', () {
    const line = ""
        "<http://example.org/show/218> "
        "<http://www.w3.org/2000/01/rdf-schema#label> "
        "\"That Seventies Show\"^^<http://www.w3.org/2001/XMLSchema#string> "
        ". "
        "# literal with XML Schema string datatype";
    final result = NTriplesParser.parseLine(line);
    expect(
        result,
        Tuple3(
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://example.org/show/218",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://www.w3.org/2000/01/rdf-schema#label",
          ),
          NTripleTerm(
            termType: NTripleTermType.literal,
            value: "That Seventies Show",
            dataType: "http://www.w3.org/2001/XMLSchema#string",
          ),
        ));
  });

  test('Literal, IRI, Literal', () {
    const line = ""
        "\"Some text\" "
        "<http://www.schema.org/something> "
        "\"Another text\" "
        ".";
    final result = NTriplesParser.parseLine(line);
    expect(
        result,
        Tuple3(
          NTripleTerm(
            termType: NTripleTermType.literal,
            value: "Some text",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://www.schema.org/something",
          ),
          NTripleTerm(
            termType: NTripleTermType.literal,
            value: "Another text",
          ),
        ));
  });

  test('Blank, IRI, Blank', () {
    const line = ""
        "_:alice "
        "<http://xmlns.com/foaf/0.1/knows> "
        "_:bob "
        ".";
    final result = NTriplesParser.parseLine(line);
    expect(
        result,
        Tuple3(
          NTripleTerm(
            termType: NTripleTermType.blankNode,
            value: "alice",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://xmlns.com/foaf/0.1/knows",
          ),
          NTripleTerm(
            termType: NTripleTermType.blankNode,
            value: "bob",
          ),
        ));
  });

  test('IRI, IRI, Literal', () {
    const line = ""
        "<http://en.wikipedia.org/wiki/Helium> "
        "<http://example.org/elements/atomicNumber> "
        "\"2\"^^<http://www.w3.org/2001/XMLSchema#integer> "
        ". "
        "# xsd:integer";
    final result = NTriplesParser.parseLine(line);
    expect(
        result,
        Tuple3(
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://en.wikipedia.org/wiki/Helium",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://example.org/elements/atomicNumber",
          ),
          NTripleTerm(
            termType: NTripleTermType.literal,
            value: "2",
            dataType: "http://www.w3.org/2001/XMLSchema#integer",
          ),
        ));
  });

  test('IRI, IRI, Literal with Language Tag', () {
    const line = ""
        "<http://example.org/show/218> "
        "<http://example.org/show/localName> "
        "\"Cette Série des Années Septante\"@fr-be "
        ".  "
        "# literal outside of ASCII range with a region subtag";
    final result = NTriplesParser.parseLine(line);
    expect(
        result,
        Tuple3(
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://example.org/show/218",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://example.org/show/localName",
          ),
          NTripleTerm(
            termType: NTripleTermType.literal,
            value: "Cette Série des Années Septante",
            languageTag: "fr-be",
          ),
        ));
  });

  test('IRI, IRI, Literal with type double', () {
    const line = ""
        "<http://en.wikipedia.org/wiki/Helium> "
        "<http://example.org/elements/specificGravity> "
        "\"1.663E-4\"^^<http://www.w3.org/2001/XMLSchema#double> "
        ".     "
        "# xsd:double";

    final result = NTriplesParser.parseLine(line);
    expect(
        result,
        Tuple3(
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://en.wikipedia.org/wiki/Helium",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://example.org/elements/specificGravity",
          ),
          NTripleTerm(
            termType: NTripleTermType.literal,
            value: "1.663E-4",
            dataType: "http://www.w3.org/2001/XMLSchema#double",
          ),
        ));
  });

  test('Literal ending with double backslashes', () {
    const line = ''
        '<http://id.nlm.nih.gov/mesh/2022/C000614727> '
        '<http://id.nlm.nih.gov/mesh/vocab#source> '
        '"Nat Rev Drug Discov. 2016 Nov 29;15(12):820-1.\\\\"@en '
        '.';

    final result = NTriplesParser.parseLine(line);
    expect(
        result,
        Tuple3(
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://id.nlm.nih.gov/mesh/2022/C000614727",
          ),
          NTripleTerm(
            termType: NTripleTermType.iri,
            value: "http://id.nlm.nih.gov/mesh/vocab#source",
          ),
          NTripleTerm(
            termType: NTripleTermType.literal,
            value: "Nat Rev Drug Discov. 2016 Nov 29;15(12):820-1.\\\\",
            languageTag: "en",
          ),
        ));
  });
}
