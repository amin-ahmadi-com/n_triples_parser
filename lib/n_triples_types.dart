import 'package:crypto/crypto.dart';
import 'package:tuple/tuple.dart';

/// This enum defines possible types of an N-Triple term.
enum NTripleTermType {
  iri,
  literal,
  blankNode,
}

/// Class containing one N-Triple term, along with its data, language tag and
/// data type (if they exist)
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
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    return other is NTripleTerm &&
        termType == other.termType &&
        value == other.value &&
        languageTag == other.languageTag &&
        dataType == other.dataType;
  }

  String get sha256Digest {
    return sha256.convert("$this".codeUnits).toString();
  }
}

/// N-Triple format, which consists of three N-Triple terms.
typedef NTriple = Tuple3<NTripleTerm, NTripleTerm, NTripleTerm>;
