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
#include "ast.h"

int yylex();
void yyerror(const char *s);

AST* new_var(int size);
AST* check_var();

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
AST *root;
%}

%define api.value.type {AST*}

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
  func_decl_list { root = new_subtree(PROGRAM_NODE, NO_TYPE, 2, $1); }
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
  %empty          { $$ = new_subtree(VAR_LIST_NODE, NO_TYPE, 0); }
| var_decl_list   { $$ = $1; }
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
  var_decl_list var_decl  { add_child($1, $2); $$ = $1; }
| var_decl              { $$ = new_subtree(VAR_LIST_NODE, NO_TYPE, 1, $1); }
;

var_decl:
  INT ID SEMI                       { new_var(0); }
| INT ID LBRACK NUM RBRACK SEMI     { new_var($4); }
;

stmt_list:
  stmt_list stmt      { add_child($1, $2); $$ = $1; }
| stmt                { $$ = new_subtree(BLOCK_NODE, NO_TYPE, 1, $1); }
;

stmt:
  assign_stmt       { $$ = $1; }
| if_stmt           { $$ = $1; }
| while_stmt        { $$ = $1; }
| return_stmt       { $$ = $1; }
| func_call SEMI    // ainda n temos nó de função lul.
;

assign_stmt:  // n sei pq começou a acusar erro D:
  lval ASSIGN arith_expr SEMI { $$ = check_assign($1, $4); } // n deveria ser $1 e $3?
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
  IF LPAREN bool_expr RPAREN block                    { $$ = check_if($3, $5); }
| IF LPAREN bool_expr RPAREN block ELSE block         { $$ = check_if_else($3, $5, $7); }
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

//   ------------------------------------------------------------------------------------------- //
AST* new_var(int size) {
    int lk_idx = lookup_var(vt, id_copy, scope);
    if (lk_idx == -1) {
        add_fresh_var(vt, id_copy, yylineno, scope, size);
    } else {
        fprintf(stderr,
            "SEMANTIC ERROR (%d): variable '%s' already declared at line %d.\n",
            yylineno, id_copy, get_var_line(vt, lk_idx));
        exit(1);
    }
        return new_node(VAR_USE_NODE, idx, get_type(vt, idx));
}

AST* check_var() {
    int lk_idx = lookup_var(vt, id_copy, scope);
    if (lk_idx == -1) {
        fprintf(stderr, "SEMANTIC ERROR (%d): variable '%s' was not declared.\n",
            yylineno, id_copy);
        exit(1);
    }
    return new_node(VAR_USE_NODE, idx, get_type(vt, idx));
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

void check_bool_expr(const char* cmd, Type t) {
    if (t != BOOL_TYPE) {
        printf("SEMANTIC ERROR (%d): conditional expression in '%s' is '%s' instead of '%s'.\n",
           yylineno, cmd, get_text(t), get_text(BOOL_TYPE));
    exit(EXIT_FAILURE);
    }
}

AST* check_if(AST *e, AST *b) {
    check_bool_expr("if", get_node_type(e));
    return new_subtree(IF_NODE, NO_TYPE, 2, e, b);
}

AST* check_if_else(AST *e, AST *b1, AST *b2) {
    check_bool_expr("if", get_node_type(e));
    return new_subtree(IF_NODE, NO_TYPE, 3, e, b1, b2);
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
