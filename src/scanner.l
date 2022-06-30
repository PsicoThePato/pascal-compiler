%option outfile="scanner.c"
%option yylineno
%option nounput
%option noinput
%option noyywrap
%{
    #include "stdio.h"
    #include "parser.h" 
    #define process_token(X) return X
%}

int_val     [0-9]+
real_val    [0-9]+"."[0-9]+
str_val     \"[^"]*\"

id          [a-zA-Z]+

ignore      [ \t\n]+
comments    \{[^}]*\}
%%

{ignore}    { }
{comments}  { }

[*/]|"and"|"or"|"mod"|"div"     {process_token(MULOP) ; }
":="                            {process_token(ASSIGNOP) ; }
"<"|">"                         {process_token(RELOP) ; }
"<>"|"<="|">="			        		{process_token(RELOP) ; }
\[															{process_token(OBRA) ; }
\]															{process_token(CBRA) ; }
\(                              {process_token(OPAR) ; }
\)                              {process_token(CPAR) ; }
\.                              {process_token(DOT) ; }
\,                              {process_token(COMMA) ; }
\;                              {process_token(SEMICOLON) ; }
\:                              {process_token(COLON)  ; }
"program"                       {process_token(PROGRAM); }
"function"			 								{process_token(FUNCTION) ;}
"var"                           {process_token(VAR); }
"integer"                       {process_token(INTEGER); }
"bool"                          {process_token(BOOL);}
"real"                          {process_token(REAL) ;}
"begin"                         {process_token(BEGINS) ; }
"end"                           {process_token(END) ; }
"do"                            {process_token(DO) ; }
"while"                         {process_token(WHILE) ; }
"if"                            {process_token(IF) ; }
"then"                          {process_token(THEN) ; }
"else"                          {process_token(ELSE) ; }
"not"                           {process_token(NOT) ; }
".."														{process_token(RANGE) ; }
"of"														{process_token(OF) ; }
"+"															{process_token(PLUS) ; }
"-"															{process_token(MINUS) ; }
{int_val}   { process_token(INT_VAL); }
{real_val}  { process_token(REAL_VAL); }
{str_val}   { process_token(STR_VAL); }

{id}        { process_token(ID); }

[\n\r\0\x0B]+                   {/*end of line chars*/}
            
            /* Be sure to keep this as the last rule */
.           { printf("LEXICAL ERROR (%d): Unknown symbol %s\n", yylineno, yytext);
              exit(EXIT_FAILURE); }
%%


