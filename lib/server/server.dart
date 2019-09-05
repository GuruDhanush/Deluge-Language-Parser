import 'package:petitparser/petitparser.dart';

import 'package:DelugeDartParser/parser/parser.dart';

class DelugeServer {
  static parseFile(String text) {
    var result = DelugeParser().parse(text);
    if (result.isSuccess) {
      return result.value;
    } else if (result.isFailure) {
      throw DelugeParserException(result.message);
    }
  }

  static parseNewLines(String text) =>
      Token.newlineParser().token().matchesSkipping(text);
}

class DelugeParserException {
  final String message;

  DelugeParserException([this.message]);

  String toString() => 'Parser error: $message';
}
