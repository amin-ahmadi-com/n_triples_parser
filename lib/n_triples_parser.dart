library n_triples_parser;

import 'dart:io';

import 'package:characters/characters.dart';
import 'package:tuple/tuple.dart';

import 'n_triple_types.dart';
import 'utils.dart' as utils;

/// A simple line-based parser for N-Triples format.
/// See https://www.w3.org/TR/n-triples/ for more info on N-Triples.
class NTriplesParser {
  /// Parses a *.nt file, while reporting on progress.
  ///
  /// onProgress parameter sends the index (0-based) of current line along with
  /// total number of lines.
  static void parseFile(
    String path, {
    Function(int current, int total)? onProgress,
    Function(NTriple nt)? onLineParsed,
    Function(String line, Object exception)? onParseError,
    bool rethrowOnError = true,
    int startingIndex = 0,
  }) async {
    parseLines(
      File(path).readAsLinesSync(),
      onProgress: onProgress,
      onLineParsed: onLineParsed,
      onParseError: onParseError,
      rethrowOnError: rethrowOnError,
      startingIndex: startingIndex,
    );
  }

  /// Parses series of lines containing N-Triples, while reporting on the progress.
  ///
  /// onProgress parameter sends the index (0-based) of current line along with
  /// total number of lines.
  static void parseLines(
    Iterable<String> lines, {
    Function(int current, int total)? onProgress,
    Function(NTriple nt)? onLineParsed,
    Function(String line, Object exception)? onParseError,
    bool rethrowOnError = true,
    int startingIndex = 0,
  }) async {
    for (int i = startingIndex; i < lines.length; i++) {
      final line = lines.elementAt(i);
      try {
        final nt = parseLine(line);
        if (onProgress != null) {
          await Future.delayed(Duration(), () => onProgress(i, lines.length));
        }
        if (onLineParsed != null) {
          await Future.delayed(Duration(), () => onLineParsed(nt));
        }
      } catch (exception) {
        if (onParseError != null) {
          await Future.delayed(Duration(), () => onParseError(line, exception));
        }
        if (rethrowOnError) {
          throw exception;
        }
      }
    }
  }

  /// Parses a single line containing N-Triple.
  static NTriple parseLine(String text) {
    final result = <NTripleTerm>[];
    var term = NTripleTerm();
    _NTriplesParserState? state;

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
        case _NTriplesParserState.parsingTerm:
          term.value += char;
          break;
        case _NTriplesParserState.parsingDataType:
          term.dataType += char;
          break;
        case _NTriplesParserState.parsingLanguageTag:
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
              state = _NTriplesParserState.parsingTerm;
            }
          }
          break;

        case ">":
          {
            if (term.termType == NTripleTermType.iri) {
              term.value = utils.removeLastCharacters(term.value, 1);
              result.add(term);
              term = NTripleTerm();
              state = null;
            } else if (term.termType == NTripleTermType.literal &&
                state == _NTriplesParserState.parsingDataType) {
              term.dataType = utils.removeFirstCharacters(term.dataType, 3);
              term.dataType = utils.removeLastCharacters(term.dataType, 1);
              term.value = utils.removeLastCharacters(term.value, 1);
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
              state = _NTriplesParserState.parsingTerm;
            } else if (term.termType == NTripleTermType.literal) {
              if (prevChar != "\\") {
                if (nextChar == "@") {
                  state = _NTriplesParserState.parsingLanguageTag;
                } else if (nextChar == "^" && nextNextChar == "^") {
                  state = _NTriplesParserState.parsingDataType;
                } else {
                  term.value = utils.removeLastCharacters(term.value, 1);
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
              state = _NTriplesParserState.parsingTerm;
            }
          }
          break;

        case " ":
        case "\t":
          {
            if (state == _NTriplesParserState.parsingTerm &&
                term.termType == NTripleTermType.blankNode) {
              term.value = utils.removeFirstCharacters(term.value, 1);
              term.value = utils.removeLastCharacters(term.value, 1);
              result.add(term);
              term = NTripleTerm();
              state = null;
            } else if (state == _NTriplesParserState.parsingLanguageTag &&
                term.termType == NTripleTermType.literal) {
              term.value = utils.removeLastCharacters(term.value, 1);
              term.languageTag =
                  utils.removeLastCharacters(term.languageTag, 1);
              term.languageTag =
                  utils.removeFirstCharacters(term.languageTag, 1);
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

enum _NTriplesParserState {
  parsingTerm,
  parsingDataType,
  parsingLanguageTag,
}
