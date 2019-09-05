import 'dart:io';

import 'package:DelugeDartParser/parser/node.dart';
import 'package:DelugeDartParser/lsp/document/sync.dart';
import 'package:petitparser/petitparser.dart';

class Util {
  static Loc toLoc(Position position) =>
      Loc(line: position.line, column: position.character);

  static Position toPosition(Loc loc) =>
      Position(line: loc.line, character: loc.column);

  static String homeDir() {
    if (Platform.isWindows) {
      return Platform.environment['UserProfile'];
    } else if (Platform.isLinux | Platform.isMacOS) {
      return Platform.environment['HOME'];
    }

    throw StateError('unsupported platform error');
  }

  //TODO: use binary search
  static Loc findLine(int startPos, int endPos, List<Token> tokens) {
    if(tokens == null) return Loc(line: 0, column: 0); 

    for (int i = 0; i < tokens.length; i++) {
      var token = tokens[i];
      if (token.stop > startPos) {
        return Loc(
            line: i, column: startPos - (i == 0 ? 0 : tokens[i - 1].stop));
      }
    }
    //for last line
    return Loc(line: tokens.length, column: 0);
  }

}
