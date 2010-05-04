/* *******************                                                        */
/*  Smt2.g
 ** Original author: cconway
 ** Major contributors: none
 ** Minor contributors (to current version): mdeters
 ** This file is part of the CVC4 prototype.
 ** Copyright (c) 2009, 2010  The Analysis of Computer Systems Group (ACSys)
 ** Courant Institute of Mathematical Sciences
 ** New York University
 ** See the file COPYING in the top-level source directory for licensing
 ** information.
 **
 ** Parser for SMT-LIB v2 input language.
 **/

grammar Smt2;

options {
  language = 'C';                  // C output for antlr
//  defaultErrorHandler = false;      // Skip the default error handling, just break with exceptions
  k = 2;
}

@header {
/**
 ** This file is part of the CVC4 prototype.
 ** Copyright (c) 2009, 2010  The Analysis of Computer Systems Group (ACSys)
 ** Courant Institute of Mathematical Sciences
 ** New York University
 ** See the file COPYING in the top-level source directory for licensing
 ** information.
 **/
}

@lexer::includes {
/** This suppresses warnings about the redefinition of token symbols between
  * different parsers. The redefinitions should be harmless as long as no
  * client: (a) #include's the lexer headers for two grammars AND (b) uses the
  * token symbol definitions.
  */
#pragma GCC system_header

/* This improves performance by ~10 percent on big inputs.
 * This option is only valid if we know the input is ASCII (or some 8-bit encoding).
 * If we know the input is UTF-16, we can use ANTLR3_INLINE_INPUT_UTF16.
 * Otherwise, we have to let the lexer detect the encoding at runtime.
 */
#define ANTLR3_INLINE_INPUT_ASCII
}

@parser::includes {
#include "expr/command.h"
#include "parser/parser.h"

namespace CVC4 {
  class Expr;
}
}

@parser::postinclude {
#include "expr/expr.h"
#include "expr/kind.h"
#include "expr/type.h"
#include "parser/antlr_input.h"
#include "parser/parser.h"
#include "util/integer.h"
#include "util/output.h"
#include "util/rational.h"
#include <vector>

using namespace CVC4;
using namespace CVC4::parser;

/* These need to be macros so they can refer to the PARSER macro, which will be defined
 * by ANTLR *after* this section. (If they were functions, PARSER would be undefined.) */
#undef PARSER_STATE 
#define PARSER_STATE ((Parser*)PARSER->super)
#undef EXPR_MANAGER
#define EXPR_MANAGER PARSER_STATE->getExprManager()
#undef MK_EXPR
#define MK_EXPR EXPR_MANAGER->mkExpr
#undef MK_CONST
#define MK_CONST EXPR_MANAGER->mkConst

/**   
 * Sets the logic for the current benchmark. Declares any logic symbols.
 *
 * @param parser the CVC4 Parser object
 * @param name the name of the logic (e.g., QF_UF, AUFLIA)
 */
static void
setLogic(Parser *parser, const std::string& name) {
  if( name == "QF_UF" ) {
    parser->mkSort("U");
  } else if(name == "QF_LRA"){
    parser->defineType("Real", parser->getExprManager()->realType());
  } else{
    // NOTE: Theory types go here
    Unhandled(name);
  }
}

static void
setInfo(Parser *parser, const std::string& flag, const SExpr& sexpr) {
  // TODO: ???
}

}

/**
 * Parses an expression.
 * @return the parsed expression, or the Null Expr if we've reached the end of the input
 */
parseExpr returns [CVC4::Expr expr]
  : term[expr]
  | EOF
  ;

/**
 * Parses a command 
 * @return the parsed command, or NULL if we've reached the end of the input
 */
parseCommand returns [CVC4::Command* cmd]
  : LPAREN_TOK c = command RPAREN_TOK { $cmd = c; }
  | EOF { $cmd = 0; }
  ;

/**
 * Parse the internal portion of the command, ignoring the surrounding parentheses.
 */
command returns [CVC4::Command* cmd]
@declarations {
  std::string name;
  Expr expr;
  Type t;
  std::vector<Type> sorts;
  SExpr sexpr;
}
  : /* set the logic */
    SET_LOGIC_TOK SYMBOL
    { name = AntlrInput::tokenText($SYMBOL);
      Debug("parser") << "set logic: '" << name << "' " << std::endl;
      setLogic(PARSER_STATE,name);
      $cmd = new SetBenchmarkLogicCommand(name); }
  | SET_INFO_TOK KEYWORD symbolicExpr[sexpr]
    { name = AntlrInput::tokenText($KEYWORD);
      setInfo(PARSER_STATE,name,sexpr);    
      cmd = new SetInfoCommand(name,sexpr); }
  | /* sort declaration */
    DECLARE_SORT_TOK symbol[name,CHECK_UNDECLARED,SYM_SORT] n=NUMERAL
    { Debug("parser") << "declare sort: '" << name << "' arity=" << n << std::endl;
      if( AntlrInput::tokenToInteger(n) > 0 ) {
        Unimplemented("Parameterized user sorts.");
      }
      PARSER_STATE->mkSort(name); 
      $cmd = new DeclarationCommand(name,EXPR_MANAGER->kindType()); }
  | /* function declaration */
    DECLARE_FUN_TOK symbol[name,CHECK_UNDECLARED,SYM_VARIABLE] 
    LPAREN_TOK sortList[sorts] RPAREN_TOK 
    sortSymbol[t]
    { Debug("parser") << "declare fun: '" << name << "' " << std::endl;
      if( sorts.size() > 0 ) {
        t = EXPR_MANAGER->mkFunctionType(sorts,t);
      }
      PARSER_STATE->mkVar(name, t); 
      $cmd = new DeclarationCommand(name,t); } 
  | /* assertion */
    ASSERT_TOK term[expr]
    { cmd = new AssertCommand(expr);   }
  | /* checksat */
    CHECKSAT_TOK 
    { cmd = new CheckSatCommand(MK_CONST(true)); }
  | EXIT_TOK
    { // TODO: Explicitly represent exit as command?
      cmd = 0; }
  ;

symbolicExpr[CVC4::SExpr& sexpr]
@declarations {
  std::vector<SExpr> children;
}
  : NUMERAL
    { sexpr = SExpr(AntlrInput::tokenText($NUMERAL)); }
  | RATIONAL
    { sexpr = SExpr(AntlrInput::tokenText($RATIONAL)); }
  | STRING_LITERAL
    { sexpr = SExpr(AntlrInput::tokenText($STRING_LITERAL)); }
  | SYMBOL
    { sexpr = SExpr(AntlrInput::tokenText($SYMBOL)); }
  | KEYWORD
    { sexpr = SExpr(AntlrInput::tokenText($KEYWORD)); }
  | LPAREN_TOK 
    (symbolicExpr[sexpr] { children.push_back(sexpr); } )* 
  	RPAREN_TOK
    { sexpr = SExpr(children); }
  ;
  
/**
 * Matches a term.
 * @return the expression representing the formula
 */
term[CVC4::Expr& expr]
@init {
  Debug("parser") << "term: " << AntlrInput::tokenText(LT(1)) << std::endl;
  Kind kind;
  std::string name;
  std::vector<Expr> args; 
} 
  : /* a built-in operator application */
    LPAREN_TOK builtinOp[kind] termList[args,expr] RPAREN_TOK 
    { if((kind == CVC4::kind::AND || kind == CVC4::kind::OR) && args.size() == 1) {
        /* Unary AND/OR can be replaced with the argument.
	       It just so happens expr should already by the only argument. */
        Assert( expr == args[0] );
      } else {
        PARSER_STATE->checkArity(kind, args.size());
        expr = MK_EXPR(kind, args);
      }
    }

  | /* A non-built-in function application */
    LPAREN_TOK 
    functionSymbol[expr]
    { args.push_back(expr); }
    termList[args,expr] RPAREN_TOK
    // TODO: check arity
    { expr = MK_EXPR(CVC4::kind::APPLY_UF,args); }

  | /* An ite expression */
    LPAREN_TOK ITE_TOK 
    term[expr]
    { args.push_back(expr); } 
    term[expr]
    { args.push_back(expr); } 
    term[expr]
    { args.push_back(expr); } 
    RPAREN_TOK
    { expr = MK_EXPR(CVC4::kind::ITE, args); }

  | /* a let binding */
    LPAREN_TOK LET_TOK LPAREN_TOK 
    { PARSER_STATE->pushScope(); }
    ( LPAREN_TOK symbol[name,CHECK_UNDECLARED,SYM_VARIABLE] term[expr] RPAREN_TOK
      { PARSER_STATE->defineVar(name,expr); } )+
    RPAREN_TOK
    term[expr]
    RPAREN_TOK
    { PARSER_STATE->popScope(); }

  | /* a variable */
    symbol[name,CHECK_DECLARED,SYM_VARIABLE]
    { expr = PARSER_STATE->getVariable(name); }

    /* constants */
  | TRUE_TOK          { expr = MK_CONST(true); }
  | FALSE_TOK         { expr = MK_CONST(false); }
  | NUMERAL
    { expr = MK_CONST( AntlrInput::tokenToInteger($NUMERAL) ); }
  | RATIONAL
    { // FIXME: This doesn't work because an SMT rational is not a valid GMP rational string
      expr = MK_CONST( AntlrInput::tokenToRational($RATIONAL) ); }
    // NOTE: Theory constants go here
  ;

/**
 * Matches a sequence of terms and puts them into the formulas
 * vector.
 * @param formulas the vector to fill with terms
 * @param expr an Expr reference for the elements of the sequence
 */   
/* NOTE: We pass an Expr in here just to avoid allocating a fresh Expr every 
 * time through this rule. */
termList[std::vector<CVC4::Expr>& formulas, CVC4::Expr& expr]
  : ( term[expr] { formulas.push_back(expr); } )+
  ;

/**
* Matches a builtin operator symbol and sets kind to its associated Expr kind.
*/
builtinOp[CVC4::Kind& kind]
@init {
  Debug("parser") << "builtin: " << AntlrInput::tokenText(LT(1)) << std::endl;
}
  : NOT_TOK      { $kind = CVC4::kind::NOT;     }
  | IMPLIES_TOK  { $kind = CVC4::kind::IMPLIES; }
  | AND_TOK      { $kind = CVC4::kind::AND;     }
  | OR_TOK       { $kind = CVC4::kind::OR;      }
  | XOR_TOK      { $kind = CVC4::kind::XOR;     }
  | EQUAL_TOK    { $kind = CVC4::kind::EQUAL;   }
  | DISTINCT_TOK { $kind = CVC4::kind::DISTINCT; }
  | GREATER_THAN_TOK
                 { $kind = CVC4::kind::GT; }
  | GREATER_THAN_TOK EQUAL_TOK
                 { $kind = CVC4::kind::GEQ; }
  | LESS_THAN_TOK EQUAL_TOK
                 { $kind = CVC4::kind::LEQ; }
  | LESS_THAN_TOK
                 { $kind = CVC4::kind::LT; }
  | PLUS_TOK     { $kind = CVC4::kind::PLUS; }
  | STAR_TOK     { $kind = CVC4::kind::MULT; }
  | TILDE_TOK    { $kind = CVC4::kind::UMINUS; }
  | MINUS_TOK    { $kind = CVC4::kind::MINUS; }
    // NOTE: Theory operators go here
  ;

/**
 * Matches a (possibly undeclared) function symbol (returning the string)
 * @param check what kind of check to do with the symbol
 */
functionName[std::string& name, CVC4::parser::DeclarationCheck check]
  :  symbol[name,check,SYM_VARIABLE] 
  ;

/**
 * Matches an previously declared function symbol (returning an Expr)
 */
functionSymbol[CVC4::Expr& fun]
@declarations {
	std::string name;
}
  : functionName[name,CHECK_DECLARED]
    { PARSER_STATE->checkFunction(name);
      fun = PARSER_STATE->getVariable(name); }
  ;
  
/**
 * Matches a sequence of sort symbols and fills them into the given vector.
 */
sortList[std::vector<CVC4::Type>& sorts]
@declarations {
  Type t;
}
  : ( sortSymbol[t] { sorts.push_back(t); })* 
  ;

/**
 * Matches the sort symbol, which can be an arbitrary symbol.
 * @param check the check to perform on the name
 */
sortName[std::string& name, CVC4::parser::DeclarationCheck check] 
  : symbol[name,check,SYM_SORT] 
  ;

sortSymbol[CVC4::Type& t]
@declarations {
  std::string name;
}
  : sortName[name,CHECK_NONE] 
  	{ t = PARSER_STATE->getSort(name); }
  | BOOL_TOK
    { t = EXPR_MANAGER->booleanType(); }
  ;

/**
 * Matches the status of the benchmark, one of 'sat', 'unsat' or 'unknown'.
 */
benchmarkStatus[ CVC4::BenchmarkStatus& status ]
  : SAT_TOK       { $status = SMT_SATISFIABLE;    }
  | UNSAT_TOK     { $status = SMT_UNSATISFIABLE;  }
  | UNKNOWN_TOK   { $status = SMT_UNKNOWN;        }
  ;

/**
 * Matches an symbol and sets the string reference parameter id.
 * @param id string to hold the symbol
 * @param check what kinds of check to do on the symbol
 * @param type the intended namespace for the symbol
 */
symbol[std::string& id,
		   CVC4::parser::DeclarationCheck check, 
           CVC4::parser::SymbolType type] 
  : SYMBOL
    { id = AntlrInput::tokenText($SYMBOL);
      Debug("parser") << "symbol: " << id
                      << " check? " << toString(check)
                      << " type? " << toString(type) << std::endl;
      PARSER_STATE->checkDeclaration(id, check, type); }
  ;

// Base SMT-LIB tokens
ASSERT_TOK : 'assert';
BOOL_TOK : 'Bool';
//CATEGORY_TOK : ':category';
CHECKSAT_TOK : 'check-sat';
//DIFFICULTY_TOK : ':difficulty';
DECLARE_FUN_TOK : 'declare-fun';
DECLARE_SORT_TOK : 'declare-sort';
EXIT_TOK : 'exit';
FALSE_TOK : 'false';
ITE_TOK : 'ite';
LET_TOK : 'let';
LPAREN_TOK : '(';
//NOTES_TOK : ':notes';
RPAREN_TOK : ')';
//SAT_TOK : 'sat';
SET_LOGIC_TOK : 'set-logic';
SET_INFO_TOK : 'set-info';
//SMT_VERSION_TOK : ':smt-lib-version';
//SOURCE_TOK : ':source';
//STATUS_TOK : ':status';
TRUE_TOK : 'true';
//UNKNOWN_TOK : 'unknown';
//UNSAT_TOK : 'unsat';

// operators (NOTE: theory symbols go here)
AMPERSAND_TOK     : '&';
AND_TOK           : 'and';
AT_TOK            : '@';
DISTINCT_TOK      : 'distinct';
DIV_TOK           : '/';
EQUAL_TOK         : '=';
EXISTS_TOK        : 'exists';
FORALL_TOK        : 'forall';
GREATER_THAN_TOK  : '>';
IMPLIES_TOK       : '=>';
LESS_THAN_TOK     : '<';
MINUS_TOK         : '-';
NOT_TOK           : 'not';
OR_TOK            : 'or';
PERCENT_TOK       : '%';
PIPE_TOK          : '|';
PLUS_TOK          : '+';
POUND_TOK         : '#';
STAR_TOK          : '*';
TILDE_TOK         : '~';
XOR_TOK           : 'xor';

/**
 * Matches a symbol from the input. A symbol is a "simple" symbol or a 
 * sequence of printable ASCII characters that starts and ends with | and 
 * does not otherwise contain |.
 */
SYMBOL
  : SIMPLE_SYMBOL
  | '|' ~('|')+ '|'
  ;

/**
 * Matches a keyword from the input. A keyword is a simple symbol prefixed
 * with a colon.
 */
KEYWORD
  : ':' SIMPLE_SYMBOL
  ;

/** Matches a "simple" symbol: a non-empty sequence of letters, digits and 
 * the characters + - / * = % ? ! . $ ~ & ^ < > @ that does not start with a 
 * digit. 
 */
fragment SIMPLE_SYMBOL 
  : (ALPHA | SYMBOL_CHAR) (ALPHA | DIGIT | SYMBOL_CHAR)*
  ;

/**
 * Matches and skips whitespace in the input.
 */
WHITESPACE
  :  (' ' | '\t' | '\f' | '\r' | '\n')+             { $channel = HIDDEN;; }
  ;

/**
 * Matches a numeral from the input (non-empty sequence of digits).
 */
NUMERAL
  : DIGIT+
  ;

RATIONAL
  : DIGIT+ '.' DIGIT+
  ;

/**
 * Matches a double quoted string literal. Escaping is supported, and escape
 * character '\' has to be escaped.
 */
STRING_LITERAL 
  :  '"' (ESCAPE | ~('"'|'\\'))* '"'
  ;

/**
 * Matches the comments and ignores them
 */
COMMENT 
  : ';' (~('\n' | '\r'))*                    { $channel = HIDDEN;; }
  ;


/**
 * Matches any letter ('a'-'z' and 'A'-'Z').
 */
fragment
ALPHA 
  :  'a'..'z'
  |  'A'..'Z'
  ;

/**
 * Matches the digits (0-9)
 */
fragment DIGIT : '0'..'9';

/** Matches the characters that may appear in a "symbol" (i.e., an identifier) 
 */
fragment SYMBOL_CHAR 
  : '+' | '-' | '/' | '*' | '=' | '%' | '?' | '!' | '.' | '$' | '_' | '~' 
  | '&' | '^' | '<' | '>' | '@'
  ;

/**
 * Matches an allowed escaped character.
 */
fragment ESCAPE : '\\' ('"' | '\\' | 'n' | 't' | 'r');

