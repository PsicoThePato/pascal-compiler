%output "parser.c"          // File name of generated parser.
%defines "parser.h"         // Produces a 'parser.h'
%define parse.error verbose // Give proper messages when a syntax error is found.
%define parse.lac full      // Enable LAC to improve syntax error handling.

%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.h"

int yylex(void);
int yylex_destroy(void);
void yyerror(char const *s);

extern char *yytext;
extern int yylineno;
%}

%token ARRAY
%token ASSIGN
%token BEGINS
%token BOOL
%token CBRA
%token COLON
%token COMMA
%token CPAR
%token DO
%token DOT
%token ELSE
%token END
%token EQ
%token FUNCTION
%token GE
%token GT
%token ID
%token IF
%token INTEGER
%token INT_VAL
%token LE
%token LT
%token MINUS
%token NEQ
%token NOT
%token OBRA
%token OF
%token OPAR
%token PLUS
%token PROCEDURE
%token PROGRAM
%token RANGE
%token REAL
%token REAL_VAL
%token SEMICOLON
%token SLASH
%token STR_VAL
%token THEN
%token TIMES
%token VAR
%token WHILE

%precedence THEN
%precedence ELSE

%%

program:
   PROGRAM ID SEMICOLON
   declarations
   subprogram_declarations
   compound_statement
   DOT
;

identifier_list:
  ID
| identifier_list COMMA ID
;

declarations:
  declarations VAR identifier_list COLON type SEMICOLON
| %empty
;

type:
  standard_type
|  ARRAY OBRA INT_VAL RANGE INT_VAL CBRA OF standard_type
;

standard_type:
  INTEGER
| REAL
| BOOL
;

subprogram_declarations:
  subprogram_declarations subprogram_declaration SEMICOLON
| %empty
;

subprogram_declaration:
  subprogram_head declarations compound_statement
;

subprogram_head:
  FUNCTION ID arguments COLON standard_type SEMICOLON
| PROCEDURE ID arguments SEMICOLON
;

arguments:
  OPAR parameter_list CPAR
| %empty
;

parameter_list:
  identifier_list COLON type
| parameter_list SEMICOLON identifier_list COLON type
;

compound_statement:
  BEGINS optional_statements END
;

optional_statements:
  statement_list
| %empty
;

statement_list:
  statement
| statement_list SEMICOLON statement
;

statement:
  variable ASSIGN expression
| procedure_statement
| compound_statement
| IF expression THEN statement
| IF expression THEN statement ELSE statement
| WHILE expression DO statement
;

variable:
  ID
| ID OBRA expression CBRA
;

procedure_statement:
  ID
| ID OPAR expression_list CPAR
;

expression_list:
  expression
|  expression_list COMMA expression
;

expression:
  simple_expression
|  simple_expression LT simple_expression
|  simple_expression GT simple_expression
|  simple_expression LE simple_expression
|  simple_expression GE simple_expression
|  simple_expression EQ simple_expression
|  simple_expression NEQ simple_expression
;

simple_expression:
  term
| sign term
| simple_expression PLUS term
| simple_expression MINUS term
;

term:
  factor
| term TIMES factor
| term SLASH factor
;

factor:
  ID
| ID OPAR expression_list CPAR
| INT_VAL
| REAL_VAL
| STR_VAL
| OPAR expression CPAR
| NOT factor
;

sign:
  PLUS
| MINUS
;

%%

void yyerror(char const *s){
    printf("SYNTAX ERROR (%d): %s\n", yylineno, s);
    exit(EXIT_FAILURE);
}

int main(void){
    yyparse();
    printf("PARSE SUCCESSFUL!\n");
}
