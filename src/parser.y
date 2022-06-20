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

%token APPEND
%token ARRAY
%token ASSIGN
%token BEGIN
%token BOOLEAN
%token CHAR
%token CLOSE
%token CLRSCR
%token CONST
%token DO
%token DOWTO
%token ELSE
%token END
%token FALSE
%token FOR
%token FUNCTION
%token GOTOXY
%token IF
%token INTEGER
%token OF
%token ORD
%token PROCEDURE
%token PROGRAM
%token READ
%token READKEY
%token READLN
%token REAL
%token RECORD
%token REPEAT
%token RESET
%token REWRITE
%token STRING
%token THEN
%token TO
%token TRUE
%token TYPE
%token UNTIL
%token VAR
%token WRITE
%token WRITELN
%token TEXTCOLOR
%token CHR
%token RED
%token YELLOW
%token LIGHTCYAN
%token LIGHTGREEN
%token LENGTH
%token TEXTBACKGROUND
%token BLINK
%token NOT
%token LIGHTGREY
%token GREEN
%token LIGHTMAGENTA
%token TEXT 
%token MOD
%token LIGHTBLUE
%token MAGENTA
%token OR
%token BROWN
%token DARKGRAY
%token AND
%token BLUE
%token CYAN
%token LIGHTRED
%token WHITE
%token DIV
%token EOF
%token DD
%token BT 
%token D
%token LC
%token RC
%token COMMA
%token INT_VAL
%token ID


//%token str_val




pascal-program: 
   program ID program-headingopt SEMI block D 
;
 
program-heading:  
   ( identifier-list ) 
 
 
identifier-list: 
   ID 
|  identifier-list COMMA ID
;
 
 
block:  
   block1  
|  label-declaration SEMI block1  
; 
 
block1:  
   block2  
|  constant-declaration SEMI block2  
; 
 
block2:  
   block3  
|  type-declaration SEMI block3  
; 
 
block3:  
   block4  
|  variable-declaration SEMI block4  
; 
 
block4:  
   block5  
|  proc-and-func-declaration SEMI block5  
; 
 
block5:  
   BEGIN statement-list END 
 
 
label-declaration:  
   label unsigned-integer  
|  label-declaration COMMA unsigned-integer  
; 
 
constant-declaration:  
   CONST  ID EQ CONST  
|  constant-declaration SEMI  ID EQ CONST  
; 
 
type-declaration:  
   TYPE  ID EQ TYPE  
|  type-declaration SEMI  ID EQ TYPE  
; 
 
variable-declaration:  
   VAR variableid-list DD TYPE 
|  variable-declaration SEMI variableid-list DD TYPE  
; 
 
variableid-list:  
   ID  
|  variableid-list COMMA  ID 
; 
 
constant:  
   INTEGER  
|  REAL
|  STRING
|  constid  
|  PLUS constid 
|  TADD- constid
;
 
 
type:  
   simple-type  
|  structured-type  
|  ^ typeid  
; 
 
simple-type:  
   (  identifier-list )  
|  CONST ... CONST  
|  typeid  
;  
 
structured-type:  
   ARRAY [ index-list ] OF TYPE 
|  record field-list END 
|  set OF simple-type  
|  file OF TYPE  
|  packed structured-type  
;
 
 
index-list:  
   simple-type  
|  index-list COMMA simple-type  
;
 
field-list:  
   fixed-part  
|  fixed-part SEMI variant-part 
|  variant-part 
; 
 
fixed-part:  
   record-field 
|  fixed-part SEMI record-field 
; 
 
record-field: 
   %empty 
|  fieldid-list DD TYPE
; 
 
fieldid-list:  
   ID 
|  fieldid-list COMMA  ID  
; 
 
variant-part: 
   case tag-field OF variant-list 
;
 
tag-field: 
   typeid  
|  ID DD typeid  
; 
 
variant-list:  
   variant 
|  variant-list SEMI variant 
; 
 
variant: 
   %empty 
|  case-label-list DD ( field-list )  
; 
 
case-label-list:  
   CONST  
|  case-label-list COMMA CONST  
; 
 
proc-and-func-declaration:  
   proc-or-func  
|  proc-and-func-declaration SEMI proc-or-func 
; 
 
proc-or-func:  
   PROCEDURE  ID parametersopt SEMI  block-or-forward 
|  FUNCTION  ID parametersopt DD typeid SEMI block-or-forward 
; 
 
block-or-forward:  
   block  
|  forward  
; 
 
parameters:  
   ( formal-parameter-list )  
 
 
formal-parameter-list:  
   formal-parameter-section  
|  formal-parameter-list SEMI formal-parameter-section  
; 
 
formal-parameter-section:  
   parameterid-list DD typeid 
|  VAR parameterid-list DD typeid  
|  PROCEDURE ID parametersopt 
|  FUNCTION ID parametersopt DD typeid 
; 
 
parameterid-list:  
   ID 
|  parameterid-list COMMA ID
; 
 
statement-list:  
   statement  
|  statement-list SEMI statement  
; 
 
statement:  
   %empty  
|  variable ASSIGN expression  
|  BEGIN statement-list END  
|  IF expression THEN statement 
|  IF expression THEN statement ELSE statement  
|  case expression OF case-list END  
|  WHILE expression DO statement  
|  REPEAT statement-list UNTIL expression  
|  FOR varid ASSIGN for-list DO statement  
|  procid  
|  procid ( expression-list )  
|  goto label 
|  with record-variable-list DO statement  
|  label DD statement  
; 
 
variable:  
   ID  
|   variable [ subscript-list ]  
|   variable D fieldid  
|   variable ^  
;
 
subscript-list:  
|   expression  
|   subscript-list COMMA expression  
; 
 
case-list:  
|   case-label-list DD statement  
|   case-list SEMI case-label-list DD statement  
; 
 
for-list:  
|  expression TO expression  
|  expression DOWNTO expression  
; 
 
expression-list:  
|   expression  
|   expression-list COMMA expression  
; 
 
label:  
   unsigned-integer 
 ;
 
record-variable-list:  
   variable 
   |record-variable-list COMMA variable 
 ;
 
expression: 
   expression
   |relational-op
   | additive-expression 
   |additive-expression  
 ;
 
relational-op: one of 
   LT
   |<=
   |EQ
   |<>
   |=>
   |GT 
 ;
 
additive-expression: 
   additive-expression
   | additive-op
   | multiplicative-expression 
   |multiplicative-expression  
 ;
 
additive-op: one of 
   ADD
   | MINUS
   | OR 
 ;
 
multiplicative-expression: 
   multiplicative-expression
   | multiplicative-op
   | unary-expression 
   |unary-expression  
; 
 
multiplicative-op: one of 
   TIMES
| OVER
| div
| MOD
| AND
| in
; 
 
 
unary-expression: 
   unary-op unary-expression  
   primary-expression  
; 
 
unary-op:  one of 
   PLUS
| MINUS
| NOT 
; 
 
primary-expression:  
   variable
|   unsigned-integer  
|   unsigned-real  
|   STRING  
|   nil  
|   funcid ( expression-list )  
|   [ element-list ]  
|   ( expression )  
; 
 
element-list:  
   %empty  
|   element  
|   element-list COMMA element  
 ;
 
element:  
|   expression  
|   expression ... expression  
 ;
 
constid:  
   ID  
 ;
 
typeid:  
   ID  
 ;
 
funcid: 
   ID  
 ;
 
procid:  
   ID  
 ;
 
fieldid:  
   ID   
 ;
 
varid: 
   ID  
 ;
 