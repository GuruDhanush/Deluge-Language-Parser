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


  Parser startParser() => 
    ref(SINGLELINE_COMMENT);

  Parser expression() => ref(IDENTIFIER) & ref(token, '=') & 
            (ref(TRUE) | ref(FALSE) | ref(BIGINT) | ref(DECIMAL));

  Parser ifexpression() => ref(IF) 
              & ref(token, '(')
              & ref(expression)
              & ref(token, ')')
              & ref(token, '{')
              & ref(expression).star()
              & ref(token, '}')
              & (ref(ELSE) 
                & ref(token, '{') 
                & ref(expression).star() 
                & ref(token, '}')).optional();  

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



  //TODO: Know whether the deluge has  no first digit rule. 
  Parser IDENTIFIER() => (ref(LETTER) | char('_'))   //no digit before
                  & (ref(LETTER) | ref(DIGIT) | char('_')).star();
  
  Parser BIGINT() => (char('-').optional() 
               & ref(DIGIT).plus())
               .flatten().trim().map(int.parse);

  Parser DECIMAL() => (char('-').optional() 
                 & (ref(DIGIT).plus() & char('.') & ref(DIGIT).plus())  //123.45
                 | (ref(DIGIT).plus() & char('.'))                      // 123.
                 | (char('.') & ref(DIGIT).plus())                      // .45
                ).flatten().map(double.parse); 

  Parser LETTER() => letter();
  Parser DIGIT() => digit();

  Parser NEWLINE() => pattern('\n\r');
  Parser SINGLELINE_COMMENT() => char('/') & char('/')
            & ref(NEWLINE).neg().star()
            & ref(NEWLINE).optional();
  
  Parser MULTILINE_COMMENT() => char('/') & char('*')
            & (char('*') & char('/')).neg().star()
            & char('*') & char('/');

  Parser STRING() => char('"') &  ref(STRING_CONTENT).star() & char('"');

  Parser STRING_CONTENT() => char('\\') & char('"') | char('"').neg();

}

