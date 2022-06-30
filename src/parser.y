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
%token BEGINS
%token DO
%token ELSE
%token END
%token FUNCTION
%token IF
%token INTEGER
%token PROGRAM
%token REAL
%token STRING
%token THEN
%token VAR
%token NOT
%token ADDOP
%token ASSIGNOP
%token MULOP
%token RELOP
%token OPAR
%token CPAR
%token DOT
%token SEMICOLON
%token COLON
%token COMMA
%token REAL_VAL
%token INT_VAL
%token ID
%token STR_VAL
%token OBRA
%token CBRA
%token RANGE
%token OF
%token PROCEDURE
%token MINUS
%token PLUS
%token WHILE
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
  declarations VAR COLON type SEMICOLON
| %empty
;	

type:
	standard_type
|	ARRAY OBRA INT_VAL RANGE CBRA OF standard_type
;

standard_type:
	INTEGER
|	REAL
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
	identifier_list COMMA type
| parameter_list SEMICOLON identifier_list COMMA type
;

compound_statement:
	BEGINS
	optional_statements
	END
;

optional_statements:
	statement_list
|	%empty
;

statement_list:
	statement
| statement_list SEMICOLON statement
;

statement:
	variable ASSIGNOP expression
| procedure_statement
| compound_statement
| IF expression THEN statement ELSE statement
| WHILE expression DO statement
;

variable:
	ID
|	ID OPAR expression CPAR
;

procedure_statement:
	ID
|	ID OPAR expression_list CPAR
;

expression_list:
	expression
|	expression_list COMMA expression
;

expression:
	simple_expression
|	simple_expression RELOP simple_expression
;

simple_expression:
	term
|	sign term
| simple_expression ADDOP term
;

term:
	factor
|	term MULOP factor
;

factor:
	ID
|	ID OPAR expression_list CPAR
|	INT_VAL
|	OPAR expression CPAR
|	NOT factor
;

sign:
	PLUS
| MINUS
;

%%
 
void yyerror(char const *s){
printf("%s\n", s);
} 


int main(void){
	if (yyparse() == 0) printf("SUCESS!\n");
	else 	printf("FAIL!\n");
	return 0;

}