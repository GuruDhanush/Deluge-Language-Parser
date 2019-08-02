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

  Parser startParser() => ref(stringLiteral);

  Parser expression() =>
      ref(identifier) &
      ref(token, '=') &
      (ref(TRUE) | ref(FALSE) | ref(BIGINT) | ref(DECIMAL) | ref(identifier));

  Parser conditionalExpression() =>
      (ref(singleParam) &
          (ref(equalityOperator) |
              ref(conditionalExpression) |
              ref(relationalOperator)) &
          ref(singleParam)) |
      ref(BOOLEAN);

  Parser qualified() => ref(identifier) & methodOrProp().star();

  Parser methodOrProp() => (ref(token, '.') & ref(identifier)) | ref(parmas);
  //Parser assignmentExpression() => ref()

  //TODO: Implement a strict version of params. 
  //An strict version of param identifier is difficult to parse, so the lenient version
  //may or maynot accept ',' between the params. 
  Parser parmas() =>
      ref(token, '(') &
      (ref(arithmeticExpression) & ref(token, ',').optional()).star() &
      ref(token, ')');


  Parser singleParam() =>
      ref(decimalLiteral) |
      ref(bigintLiteral) |
      ref(booleanLiteral) |
      ref(identifier) |
      ref(stringLiteral) |
      ref(bracketParam);

  Parser bracketParam() =>
      ref(token, '(') & ref(arithmeticExpression) & ref(token, ')');

  Parser arithmeticExpression() =>
      ref(singleParam) & (ref(arithemticOperator) & ref(singleParam)).star();
  
  Parser callExpression() => (ref(memberExpression) | ref(arithmeticExpression))  & ref(parmas);

  Parser memberExpression() => ref(arithmeticExpression) & ref(token, '.') & ref(arithmeticExpression);

  Parser decimalLiteral() => ref(token, DECIMAL);
  Parser bigintLiteral() => ref(token, BIGINT);
  Parser stringLiteral() => ref(token, STRING);
  Parser booleanLiteral() => ref(token, BOOLEAN);

  Parser identifier() => ref(token, IDENTIFIER);

  Parser ifexpression() =>
      ref(IF) &
      ref(token, '(') &
      ref(conditionalExpression) &
      ref(token, ')') &
      ref(token, '{') &
      ref(expression).star() &
      ref(token, '}') &
      (ref(ELSE) & ref(token, '{') & ref(expression).star() & ref(token, '}'))
          .optional();

  Parser zohoSysVariables() =>
      ref(ZOHO) &
      char('.') &
      (ref(token, 'currentdate') |
          ref(token, 'currenttime') |
          ref(token, 'loginuser') |
          ref(token, 'loginuserid') |
          ref(token, 'adminuser') |
          ref(token, 'adminuserid') |
          ref(token, 'appname') |
          ref(token, 'ipaddress') |
          ref(token, 'appuri'));

  //TODO: works only with bigint
  Parser list() =>
      (ref(token, '{') &
          ((ref(BIGINT) & ref(token, ',')).star() & ref(BIGINT)).optional() &
          ref(token, '}')) |
      (ref(token, '[') &
          ((ref(BIGINT) & ref(token, ',')).star() & ref(BIGINT)).optional() &
          ref(token, ']'));

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
      ref(token, '>') | ref(token, '>=') | ref(token, '<') | ref(token, '<=');

  Parser conditionalOperator() => ref(token, '&&') | ref(token, '||');
  Parser prefixConditionalOperator() => ref(token, '!');
  Parser listOperator() => ref(IN) & ref(NOT).optional();

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

  //TODO: Know whether the deluge has  no first digit rule.
  Parser IDENTIFIER() => ((ref(LETTER) | char('_')) //no digit before
          &
          (ref(LETTER) | ref(DIGIT) | char('_')).star())
      .flatten();

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
  Parser SINGLELINE_COMMENT() =>
      char('/') &
      char('/') &
      ref(NEWLINE).neg().star() &
      ref(NEWLINE).optional();

  Parser MULTILINE_COMMENT() =>
      char('/') &
      char('*') &
      (char('*') & char('/')).neg().star() &
      char('*') &
      char('/');

  Parser STRING() =>
      (char('"') & ref(STRING_CONTENT).star() & char('"')).pick(1);

  Parser STRING_CONTENT() => char('\\') & char('"') | char('"').neg();
}
