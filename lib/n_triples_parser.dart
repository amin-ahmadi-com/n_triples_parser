library n_triples_parser;

import 'package:tuple/tuple.dart';
import 'utils.dart' as utils;
import 'package:characters/characters.dart';

enum NTripleTermType {
  iri,
  literal,
  blankNode,
}

class NTripleTerm {
  NTripleTermType? termType;
  String value;
  String languageTag;
  String dataType;

  NTripleTerm({
    this.termType,
    this.value = "",
    this.languageTag = "",
    this.dataType = "",
  });

  @override
  String toString() {
    return "$termType : $value @$languageTag ^^$dataType";
  }

  @override
  bool operator ==(Object other) {
    return other is NTripleTerm &&
        termType == other.termType &&
        value == other.value &&
        languageTag == other.languageTag &&
        dataType == other.dataType;
  }
}

typedef NTriple = Tuple3<NTripleTerm, NTripleTerm, NTripleTerm>;

enum NTripleParserState {
  parsingTerm,
  parsingDataType,
  parsingLanguageTag,
}

class NTriplesParser {
  static NTriple parseLine(String text) {
    final result = <NTripleTerm>[];
    var term = NTripleTerm();
    NTripleParserState? state;

    for (int i = 0; i < text.characters.length; i++) {
      final char = text.characters.elementAt(i);
      final prevChar = i > 0 ? text.characters.elementAt(i - 1) : "";
      final nextChar = i < text.characters.length - 2
          ? text.characters.elementAt(i + 1)
          : "";
      final nextNextChar = i < text.characters.length - 3
          ? text.characters.elementAt(i + 2)
          : "";

      switch (state) {
        case NTripleParserState.parsingTerm:
          term.value += char;
          break;
        case NTripleParserState.parsingDataType:
          term.dataType += char;
          break;
        case NTripleParserState.parsingLanguageTag:
          term.languageTag += char;
          break;
        case null:
          break;
      }

      switch (char) {
        case "<":
          {
            if (state == null) {
              term = NTripleTerm(termType: NTripleTermType.iri);
              state = NTripleParserState.parsingTerm;
            }
          }
          break;

        case ">":
          {
            if (term.termType == NTripleTermType.iri) {
              term.value = utils.removeLastCharacter(term.value);
              result.add(term);
              term = NTripleTerm();
              state = null;
            } else if (term.termType == NTripleTermType.literal &&
                state == NTripleParserState.parsingDataType) {
              term.dataType = term.dataType.substring(3);
              term.dataType = utils.removeLastCharacter(term.dataType);
              term.value = utils.removeLastCharacter(term.value);
              result.add(term);
              term = NTripleTerm();
              state = null;
            }
          }
          break;

        case ".":
          {
            if (state == null) {
              break;
            }
          }
          break;

        case "#":
          {
            if (state == null) {
              break;
            }
          }
          break;

        case "\"":
          {
            if (state == null) {
              term = NTripleTerm(termType: NTripleTermType.literal);
              state = NTripleParserState.parsingTerm;
            } else if (term.termType == NTripleTermType.literal) {
              if (prevChar != "\\") {
                if (nextChar == "@") {
                  state = NTripleParserState.parsingLanguageTag;
                } else if (nextChar == "^" && nextNextChar == "^") {
                  state = NTripleParserState.parsingDataType;
                } else {
                  term.value = utils.removeLastCharacter(term.value);
                  result.add(term);
                  term = NTripleTerm();
                  state = null;
                }
              }
            }
          }
          break;

        case "_":
          {
            if (state == null && nextChar == ":") {
              term = NTripleTerm(termType: NTripleTermType.blankNode);
              state = NTripleParserState.parsingTerm;
            }
          }
          break;

        case " ":
        case "\t":
          {
            if (state == NTripleParserState.parsingTerm &&
                term.termType == NTripleTermType.blankNode) {
              term.value = term.value.substring(1);
              term.value = utils.removeLastCharacter(term.value);
              result.add(term);
              term = NTripleTerm();
              state = null;
            } else if (state == NTripleParserState.parsingLanguageTag &&
                term.termType == NTripleTermType.literal) {
              term.value = utils.removeLastCharacter(term.value);
              term.languageTag = utils.removeLastCharacter(term.languageTag);
              term.languageTag = term.languageTag.substring(1);
              result.add(term);
              term = NTripleTerm();
              state = null;
            }
          }
          break;
      }
    }

    if (result.length != 3) throw Exception("Incorrect N-Triples line syntax");

    return Tuple3(result[0], result[1], result[2]);
  }
}
