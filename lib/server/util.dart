import 'dart:io';

import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/document/sync.dart';
import 'package:DelugeDartParser/server/messaging/message.dart';

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
}
