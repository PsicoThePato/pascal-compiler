
%output "parser.c"
%defines "parser.h"
%define parse.error verbose
%define parse.lac full
%define parse.trace

%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "parser.h"
#include "tables.h"

int yylex();
void yyerror(const char *s);

void new_var(int size);
void check_var();

int new_func();
void add_params(int id);

int new_fcall();
void check_fcall(int id);

extern int yylineno;
extern char id_copy[64];

LitTable *lt;
VarTable *vt;
FuncTable *ft;

int scope;
int param_count;
int arg_count;
%}

%token ELSE IF INPUT INT OUTPUT RETURN VOID WHILE WRITE
%token SEMI COMMA LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE
%token ASSIGN
%token LT LE GT GE EQ NEQ

%token NUM
%token ID
%token STRING

%left PLUS MINUS
%left TIMES OVER

%start program

%%

program:
  func_decl_list
;

func_decl_list:
  func_decl_list func_decl
| func_decl
;

func_decl:
  func_header func_body     { scope++; }
;

func_header:
  ret_type ID { $2 = new_func(); } LPAREN params RPAREN { add_params($2); }
;

func_body:
  LBRACE opt_var_decl opt_stmt_list RBRACE
;

opt_var_decl:
  %empty
| var_decl_list
;

opt_stmt_list:
  %empty
| stmt_list
;

ret_type:
  INT
| VOID
;

params:
  VOID
| param_list
;

param_list:
  param_list COMMA param    { param_count++; }
| param                     { param_count++; }
;

param:
  INT ID                { new_var(0); }
| INT ID LBRACK RBRACK  { new_var(-1); }
;

var_decl_list:
  var_decl_list var_decl
| var_decl
;

var_decl:
  INT ID SEMI                       { new_var(0); }
| INT ID LBRACK NUM RBRACK SEMI     { new_var($4); }
;

stmt_list:
  stmt_list stmt
| stmt
;

stmt:
  assign_stmt
| if_stmt
| while_stmt
| return_stmt
| func_call SEMI
;

assign_stmt:
  lval ASSIGN arith_expr SEMI
;

id_var:
    ID { check_var(); }
;

lval:
  id_var
| id_var LBRACK NUM RBRACK
| id_var LBRACK ID { check_var(); } RBRACK
;

if_stmt:
  IF LPAREN bool_expr RPAREN block
| IF LPAREN bool_expr RPAREN block ELSE block
;

block:
  LBRACE opt_stmt_list RBRACE
;

while_stmt:
  WHILE LPAREN bool_expr RPAREN block
;

return_stmt:
  RETURN SEMI
| RETURN arith_expr SEMI
;

func_call:
  output_call
| write_call
| user_func_call
;

input_call:
  INPUT LPAREN RPAREN
;

output_call:
  OUTPUT LPAREN arith_expr RPAREN
;

write_call:
  WRITE LPAREN STRING RPAREN
;

user_func_call:
  ID { $1 = new_fcall(); } LPAREN opt_arg_list RPAREN { check_fcall($1); }
;

opt_arg_list:
  %empty
| arg_list
;

arg_list:
  arg_list COMMA arith_expr     { arg_count++; }
| arith_expr                    { arg_count++; }
;

bool_expr:
  arith_expr LT arith_expr
| arith_expr LE arith_expr
| arith_expr GT arith_expr
| arith_expr GE arith_expr
| arith_expr EQ arith_expr
| arith_expr NEQ arith_expr
;

arith_expr:
  arith_expr PLUS arith_expr
| arith_expr MINUS arith_expr
| arith_expr TIMES arith_expr
| arith_expr OVER arith_expr
| LPAREN arith_expr RPAREN
| lval
| input_call
| user_func_call
| NUM
;

%%

void new_var(int size) {
    int lk_idx = lookup_var(vt, id_copy, scope);
    if (lk_idx == -1) {
        add_fresh_var(vt, id_copy, yylineno, scope, size);
    } else {
        fprintf(stderr,
            "SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
            yylineno, id_copy, get_var_line(vt, lk_idx));
        exit(1);
    }
}

void check_var() {
    int lk_idx = lookup_var(vt, id_copy, scope);
    if (lk_idx == -1) {
        fprintf(stderr, "SEMANTIC ERROR (%d): variable '%s' was not declared.\n",
            yylineno, id_copy);
        exit(1);
    }
}

int new_func() {
    int lk_idx = lookup_func(ft, id_copy);
    if (lk_idx == -1) {
        int ft_idx = add_fresh_func(ft, id_copy, yylineno);
        param_count = 0;
        return ft_idx;
    } else {
        fprintf(stderr,
            "SEMANTIC ERROR (%d): function '%s' already declared at line %d.\n",
            yylineno, id_copy, get_func_line(ft, lk_idx));
        exit(1);
    }
}

void add_params(int id) {
    set_func_arity(ft, id, param_count);
}

int new_fcall() {
    int lk_idx = lookup_func(ft, id_copy);
    if (lk_idx != -1) {
        arg_count = 0;
        return lk_idx;
    } else {
        fprintf(stderr, "SEMANTIC ERROR (%d): function '%s' was not declared.\n",
            yylineno, id_copy);
        exit(1);
    }
}

void check_fcall(int id) {
    int farity = get_func_arity(ft, id);
    if (arg_count != farity) {
        fprintf(stderr,
        "SEMANTIC ERROR (%d): function '%s' was called with %d arguments but declared with %d parameters.\n",
        yylineno, get_func_name(ft, id), arg_count, farity);
        exit(1);
    }
}

// Error handling.
void yyerror (char const *s) {
    fprintf(stderr, "PARSE ERROR (%d): %s\n", yylineno, s);
    exit(1);
}

// Main.
int main() {
    yydebug = 0; // Toggle this variable to enter debug mode.

    // Initialization of tables before parsing.
    lt = create_lit_table();
    vt = create_var_table();
    ft = create_func_table();
    scope = 0;

    if (yyparse() == 0) {
        fprintf(stderr, "PARSE SUCCESSFUL!\n\n");
        print_lit_table(lt); fprintf(stderr, "\n\n");
        print_var_table(vt); fprintf(stderr, "\n\n");
        print_func_table(ft);
    }

    free_lit_table(lt);
    free_var_table(vt);
    free_func_table(ft);

    return 0;
}

