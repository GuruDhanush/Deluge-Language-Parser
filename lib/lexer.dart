import 'package:petitparser/petitparser.dart';

class DgGrammar extends GrammarParser {
  DgGrammar() : super(DgGrammarDef());
}

class DgGrammarDef extends GrammarDefinition {
  Parser token(Object input) {
    if (input is Parser) {
      return input.token().trim();
    } else if (input is String) {
      return token(input.length == 1 ? char(input) : string(input));
    } else if (input is Function) {
      return token(ref(input));
    }
    throw ArgumentError.value(input, 'invalid token parser');
  }

  Parser start() => ref(startParser).end();

  Parser startParser() => ref(statements);

  Parser params() =>
      ref(token, '(') &
      (ref(binaryExpression) |
              ref(logicalExpression) |
              ref(singleParam) |
              ref(whitespace).star())
          .separatedBy(ref(token, ','),
              includeSeparators: false, optionalSeparatorAtEnd: false) &
      ref(token, ')');

  Parser singleParam() =>
      ref(decimalLiteral) |
      ref(bigintLiteral) |
      ref(NULL) |
      ref(booleanLiteral) |
      ref(callExpression) |
      ref(memberExpression) |
      ref(invokeFunction) |
      ref(identifier) |
      ref(stringLiteral) |
      ref(bracketExpression) |
      ref(listExpression) |
      ref(objectExpression) |
      ref(token, '(') & ref(singleParam) & ref(token, ')') |
      ref(unaryExpression);

  Parser unaryExpression() => ref(prefixConditionalOperator) & ref(singleParam);

  Parser binaryExpression() =>
      (ref(singleParam)) &
      ((ref(arithemticOperator) |
                  ref(equalityOperator) |
                  ref(relationalOperator)) &
              (ref(singleParam)))
          .star();

  Parser bracketExpression() =>
      ref(token, '(') &
      (ref(binaryExpression) | ref(logicalExpression)) &
      ref(token, ')');

  Parser logicalExpression() =>
      ref(binaryExpression) &
      (ref(conditionalOperator) & ref(binaryExpression)).star();

  Parser callExpression() =>
      ((ref(memberExpression) | ref(identifier) | ref(bracketExpression)) &
          ref(params)) &
      (ref(token, '.') & ref(identifier) & ref(params).optional()).star();

  Parser memberExpression() =>
      ((ref(identifier) | ref(bracketExpression)) &
          ref(token, '.') &
          ref(identifier)) &
      (ref(token, '.') & ref(identifier) & ref(params).optional()).star();

  Parser assignmentExpression() =>
      (ref(memberExpression) | ref(identifier)) &
      ref(assignmentOperator) &
      (ref(ifExpression) |
          ref(ifNullExpression) |
          ref(logicalExpression) |
          ref(binaryExpression) |
          ref(callExpression) |
          ref(memberExpression));

  Parser expressionStatement() =>
      (ref(CONTINUE) |
          ref(BREAK) |
          ref(assignmentExpression) |
          ref(callExpression) |
          ref(memberExpression) |
          ref(infoExpression)) &
      ref(token, ';');

  Parser statement() =>
      ref(token, SINGLELINE_COMMENT) |
      ref(token, MULTILINE_COMMENT) |
      ref(returnStatement) |
      ref(ifStatement) |
      ref(forStatement) |
      ref(expressionStatement);

  Parser statements() => ref(statement).star();

  Parser infoExpression() =>
      ref(INFO) & (ref(binaryExpression) | ref(singleParam));

  Parser returnStatement() => ref(RETURN) & ref(singleParam) & ref(token, ';');

  //TODO: look after binary expressions in single params
  Parser ifNullExpression() =>
      ref(IFNULL) &
      ref(token, '(') &
      ref(singleParam) &
      ref(token, ',') &
      ref(singleParam) &
      ref(token, ')');
  //TODO: look after binary expressions in single params
  Parser ifExpression() =>
      ref(IF) &
      ref(token, '(') &
      (ref(logicalExpression) | ref(binaryExpression) | ref(singleParam)) &
      ref(token, ',') &
      ref(singleParam) &
      ref(token, ',') &
      ref(singleParam) &
      ref(token, ')');

  Parser objectProperty() =>
      ref(singleParam) &
      ref(token, ':') &
      (ref(logicalExpression) | ref(binaryExpression) | ref(singleParam));
  Parser objectBody() => ref(objectProperty)
      .separatedBy(ref(token, ','), includeSeparators: false);
  Parser listBody() =>
      ref(singleParam).separatedBy(ref(token, ','), includeSeparators: false);
  Parser listExpression() =>
      ref(token, '[') & ref(listBody).optional() & ref(token, ']') |
      ref(token, '{') & ref(listBody).optional() & ref(token, '}');
  Parser objectExpression() =>
      ref(token, '{') & ref(objectBody).optional() & ref(token, '}');

  Parser decimalLiteral() => ref(token, DECIMAL);
  Parser bigintLiteral() => ref(token, BIGINT);
  Parser stringLiteral() => ref(token, STRING);
  Parser booleanLiteral() => ref(BOOLEAN);

  Parser identifier() => ref(token, IDENTIFIER);

  Parser blockStatement() =>
      ref(token, '{') & ref(statements) & ref(token, '}');

  Parser ifStatement() =>
      ref(IF) &
      ref(token, '(') &
      (ref(logicalExpression) | ref(binaryExpression) | ref(singleParam)) &
      ref(token, ')') &
      ref(blockStatement) &
      (ref(ELSE) &
              ref(IF) &
              ref(token, '(') &
              (ref(logicalExpression) |
                  ref(binaryExpression) |
                  ref(singleParam)) &
              ref(token, ')') &
              ref(blockStatement))
          .star() &
      (ref(ELSE) & ref(blockStatement)).optional();

  Parser forStatement() =>
      ref(FOR) &
      ref(EACH) &
      ref(INDEX).optional() &
      ref(identifier) &
      ref(IN) &
      ref(singleParam) &
      ref(blockStatement);

  Parser invokeFunction() =>
      ref(identifier) &
      ref(token, '[') &
      (ref(identifier) &
              ref(token, ':') &
              (ref(logicalExpression) |
                  ref(binaryExpression) |
                  ref(singleParam)))
          .star() &
      ref(token, ']');

  //TODO: Move out from grammar to analysis phase?
  // Parser zohoSysVariables() =>
  //     ref(ZOHO) &
  //     char('.') &
  //     (ref(token, 'currentdate') |
  //         ref(token, 'currenttime') |
  //         ref(token, 'loginuser') |
  //         ref(token, 'loginuserid') |
  //         ref(token, 'adminuser') |
  //         ref(token, 'adminuserid') |
  //         ref(token, 'appname') |
  //         ref(token, 'ipaddress') |
  //         ref(token, 'appuri'));

  Parser arithemticOperator() =>
      ref(token, '+') |
      ref(token, '-') |
      ref(token, '*') |
      ref(token, '/') |
      ref(token, '%');

  Parser assignmentOperator() =>
      ref(token, '=') |
      ref(token, '+=') |
      ref(token, '-=') |
      ref(token, '*=') |
      ref(token, '/=') |
      ref(token, '%=');

  Parser equalityOperator() => ref(token, '==') | ref(token, '!=');

  Parser prefixOperator() => ref(token, '+') | ref(token, '-');

  Parser relationalOperator() =>
      ref(token, '>=') | ref(token, '>') | ref(token, '<=') | ref(token, '<');

  Parser conditionalOperator() => ref(token, '&&') | ref(token, '||');
  Parser prefixConditionalOperator() => ref(token, '!');

  //
  // Keyword definitions
  //
  Parser INFO() => ref(token, 'info');
  Parser IF() => ref(token, 'if');
  Parser ELSE() => ref(token, 'else');
  Parser RETURN() => ref(token, 'return');
  Parser IFNULL() => ref(token, 'ifnull');
  Parser BREAK() => ref(token, 'break');
  Parser CONTINUE() => ref(token, 'continue');
  Parser FOR() => ref(token, 'for');
  Parser EACH() => ref(token, 'each');
  Parser IN() => ref(token, 'in');
  Parser TRUE() => ref(token, 'true');
  Parser FALSE() => ref(token, 'false');
  Parser NOT() => ref(token, 'not');
  Parser ZOHO() => ref(token, 'zoho');
  Parser SENDMAIL() => ref(token, 'sendemail');
  Parser INDEX() => ref(token, 'index');
  Parser NULL() => ref(token, 'null');

  //TODO: Know whether the deluge has  no first digit rule.
  // It always will be  ¯\_(ツ)_/¯ .
  Parser IDENTIFIER() => ((ref(LETTER) | char('_')) //no digit before
          &
          (ref(LETTER) | ref(DIGIT) | char('_')).star())
      .flatten();

  List<String> months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec'
  ];

  Parser MONTH() => ref(token, pattern(months.join('|')));
  Parser YEAR() => ref(DIGIT).plus();
  Parser DATE() => ref(DIGIT).plus();
  Parser HOUR() => ref(DIGIT).star();
  Parser MINUTE() => ref(DIGIT).star();
  Parser SECOND() => ref(DIGIT).star();

  Parser DATESEPERATOR() => ref(token, '-');
  Parser TIMESEPERATOR() => ref(token, ':');
  Parser DATETIME() =>
      ref(token, "'") &
      ref(DATE) &
      ref(DATESEPERATOR) &
      ref(MONTH) &
      ref(DATESEPERATOR) &
      ref(YEAR) &
      ref(whitespace().plus) &
      (ref(HOUR) &
              ref(TIMESEPERATOR) &
              ref(MINUTE) &
              ref(TIMESEPERATOR) &
              ref(SECOND))
          .optional() &
      ref(token, "'");

  Parser BOOLEAN() => ref(TRUE) | ref(FALSE);

  Parser BIGINT() => (ref(prefixOperator).optional() & ref(DIGIT).plus())
      .flatten()
      .trim()
      .map(int.parse);
  

  Parser DECIMAL() => (ref(prefixOperator).optional() &
              (ref(DIGIT).plus() & char('.') & ref(DIGIT).plus()) //123.45
          |
          (ref(DIGIT).plus() & char('.')) // 123.
          |
          (char('.') & ref(DIGIT).plus()) // .45
      )
      .flatten()
      .map(double.parse);

  Parser LETTER() => letter();
  Parser DIGIT() => digit();

  Parser NEWLINE() => pattern('\n\r');
  //TODO: potential perf issues with starGreedy otherwise stops after finding \n
  Parser SINGLELINE_COMMENT() =>
      char('/') &
      char('/') &
      ref(NEWLINE).neg().star() &
      ref(NEWLINE).optional();

  Parser MULTILINE_COMMENT() =>
      char('/') &
      char('*') &
      (ref(MULTILINE_COMMENT) | string('*/').neg()).star() &
      char('*') &
      char('/');

  Parser STRING() => char('"') & ref(CHAR_PRIMITIVE).star() & char('"');

  Parser CHAR_PRIMITIVE() =>
      (char('\\') & pattern(escapeChars.join())).flatten() | pattern('^"\\');

  List escapeChars = ['"', '\\', '/', 'b', 'f', 'n', 'r', 't'];
}
