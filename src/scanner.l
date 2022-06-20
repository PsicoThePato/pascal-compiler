/* Flex output */
%option outfile="scanner.c"
/* Unused functions */
%option noyywrap
%option nounput
%option noinput
/* Auto increment variable yylineno every time a '\n' is read. */
%option yylineno

%{

#include "parser.h"

#define process_token(type) return type

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


"append"     { process_token(APPEND); }
"array"      { process_token(ARRAY);  }
"assign"     { process_token(ASSIGN); }
"begin"      { process_token(BEGIN);  }
"boolean"    { process_token(BOOLEAN); }
"char"       { process_token(CHAR);  }
"close"      { process_token(CLOSE);  }
"clrscr"     { process_token(CLRSCR);  }
"const"      { process_token(CONST);  }
"do"         { process_token(DO);  }
"downto"      { process_token(DOWNTO); }
"else"       { process_token(ELSE); }
"end"        { process_token(END); }
"false"      { process_token(FALSE); }
"for"        { process_token(FOR);  }
"function"   { process_token(FUNCTION);  }
"gotoxy"     { process_token(GOTOXY);  }
"if"         { process_token(IF); }
"integer"   { process_token(INTEGER); }
"of"         { process_token(OF);  }
"ord"        { process_token(ORD);  }
"procedure"  { process_token(PROCEDURE);  }
"program"    { process_token(PROGRAM); }
"read"       { process_token(READ); }
"readkey"    { process_token(READKEY);  }
"readln"     { process_token(READLN);  }   
"real"       { process_token(REAL); }
"record"     { process_token(RECORD);  }
"repeat"     { process_token(REPEAT); }
"reset"      { process_token(RESET);  }
"rewrite"    { process_token(REWRITE);  }
"string"     { process_token(STRING); }
"then"       { process_token(THEN); }
"to"         { process_token(TO);  }
"true"       { process_token(TRUE); }
"type"       { process_token(TYPE);  }
"until"      { process_token(UNTIL); }
"var"        { process_token(VAR); }
"write"      { process_token(WRITE); }
"writeln"    { process_token(WRITELN);  }
"textcolor"  { process_token(TEXTCOLOR);  }
"chr"        { process_token(CHR);  }
"red"        { process_token(RED);  }
"yellow"     { process_token(YELLOW);  }
"lightcyan"  { process_token(LIGHTCYAN);  }
"lightgreen" { process_token(LIGHTGREEN);  }
"length"     { process_token(LENGTH);  }
"textbackground"    { process_token(TEXTBACKGROUND);  }
"blink"     { process_token(BLINK);  }
"not"       { process_token(NOT);  }
"lightgrey" { process_token(LIGHTGREY);  }
"green"     { process_token(GREEN);  }
"lightmagenta"      { process_token(LIGHTMAGENTA);  }
"text"      { process_token(TEXT);  }
"mod"       { process_token(MOD);  }
"lightblue" { process_token(LIGHTBLUE);  }
"magenta"   { process_token(MAGENTA);  }
"or"        { process_token(OR);  }
"brown"     { process_token(BROWN);  }
"darkgray"  { process_token(DARKGRAY);  }
"and"       { process_token(AND);  }
"blue"      { process_token(BLUE);  }
"cyan"      { process_token(CYAN);  }
"lightred"  { process_token(LIGHTRED);  }
"white"     { process_token(WHITE);  }
"div"       { process_token(DIV);  }
"eof"       { process_token(EOF);  }


":"          { process_token(DD);  }
">"         { process_token(GT);  }
"."         { process_token(D);  }
"["         { process_token(LB);  }
","         { process_token(COMMA);  }
"]"         { process_token(RB);  }

":="        { process_token(ASSIGN); }
"="         { process_token(EQ); }
"("         { process_token(LPAR); }
"<"         { process_token(LT); }
"-"         { process_token(MINUS); }
"/"         { process_token(OVER); }
"+"         { process_token(PLUS); }
")"         { process_token(RPAR); }
";"         { process_token(SEMI); }
"*"         { process_token(TIMES); }

{int_val}   { process_token(INT_VAL); }
{id}        { process_token(ID); }



.           { printf("LEXICAL ERROR (%d): Unknown symbol %s\n", yylineno, yytext);
              exit(EXIT_FAILURE); }

%%