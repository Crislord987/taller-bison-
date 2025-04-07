%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <ctype.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern char* yytext;

void yyerror(const char *s);

/* Symbol table for variables and functions */
#define MAX_SYMBOLS 100
#define MAX_PARAMS 10
#define MAX_NAME_LEN 50

typedef struct {
    char name[MAX_NAME_LEN];
    double value;
} Variable;

typedef struct {
    char name[MAX_NAME_LEN];
    char params[MAX_PARAMS][MAX_NAME_LEN];
    int param_count;
    char* body;
} Function;

Variable variables[MAX_SYMBOLS];
int var_count = 0;

Function functions[MAX_SYMBOLS];
int func_count = 0;

/* Expression structure */
typedef struct Expr {
    double value;
} Expr;

/* Function to find or create variable */
int find_variable(const char* name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            return i;
        }
    }
    
    /* Create new variable if not found */
    if (var_count < MAX_SYMBOLS) {
        strcpy(variables[var_count].name, name);
        variables[var_count].value = 0.0;
        return var_count++;
    }
    
    yyerror("Too many variables");
    return -1;
}

/* Function to find function by name */
int find_function(const char* name) {
    for (int i = 0; i < func_count; i++) {
        if (strcmp(functions[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

/* Create a new function */
int create_function(const char* name) {
    if (func_count >= MAX_SYMBOLS) {
        yyerror("Too many functions");
        return -1;
    }
    
    strcpy(functions[func_count].name, name);
    functions[func_count].param_count = 0;
    return func_count++;
}

/* Add parameter to the current function */
void add_param(int func_idx, const char* param) {
    if (functions[func_idx].param_count < MAX_PARAMS) {
        strcpy(functions[func_idx].params[functions[func_idx].param_count], param);
        functions[func_idx].param_count++;
    } else {
        yyerror("Too many parameters");
    }
}

/* Helper functions for expressions */
Expr* make_number(double val) {
    Expr* e = (Expr*)malloc(sizeof(Expr));
    e->value = val;
    return e;
}

Expr* make_variable(const char* name) {
    int idx = find_variable(name);
    Expr* e = (Expr*)malloc(sizeof(Expr));
    e->value = variables[idx].value;
    return e;
}

Expr* make_binary(char op, Expr* left, Expr* right) {
    Expr* e = (Expr*)malloc(sizeof(Expr));
    switch (op) {
        case '+': e->value = left->value + right->value; break;
        case '-': e->value = left->value - right->value; break;
        case '*': e->value = left->value * right->value; break;
        case '/': e->value = left->value / right->value; break;
    }
    free(left);
    free(right);
    return e;
}

/* For function calls, we need temporary variable storage */
double temp_vars[MAX_PARAMS];

Expr* call_function(const char* name, Expr** args, int arg_count) {
    int func_idx = find_function(name);
    if (func_idx == -1) {
        yyerror("Undefined function");
        return make_number(0);
    }
    
    Function* func = &functions[func_idx];
    
    if (arg_count != func->param_count) {
        yyerror("Wrong number of arguments");
        return make_number(0);
    }
    
    /* Save original variable values and set arguments */
    double saved_values[MAX_PARAMS];
    for (int i = 0; i < func->param_count; i++) {
        int var_idx = find_variable(func->params[i]);
        saved_values[i] = variables[var_idx].value;
        variables[var_idx].value = args[i]->value;
        free(args[i]);
    }
    free(args);  /* Free the array itself */
    
    /* TODO: Evaluate function body */
    /* This is simplified - a proper implementation would need to parse and evaluate the body */
    Expr* result = make_number(0);  /* Placeholder */
    
    /* Restore original variable values */
    for (int i = 0; i < func->param_count; i++) {
        int var_idx = find_variable(func->params[i]);
        variables[var_idx].value = saved_values[i];
    }
    
    return result;
}
%}

%union {
    double dval;
    char sval[50];
    struct Expr* expr;
    struct ExprList* expr_list;
}

%token <dval> NUMBER
%token <sval> IDENTIFIER
%token DEF END
%token ASSIGN

%left '+' '-'
%left '*' '/'

%type <expr> expr
%type <expr> function_call
/* Note: A full implementation would need additional types */

%%

program:
    statement_list
    ;

statement_list:
    /* empty */
    | statement_list statement
    ;

statement:
    expr '\n'                   { printf("Result: %g\n", $1->value); free($1); }
    | IDENTIFIER ASSIGN expr '\n' {
        int idx = find_variable($1);
        variables[idx].value = $3->value;
        free($3);
    }
    | function_definition '\n'
    | '\n'                     /* ignore empty lines */
    ;

expr:
    NUMBER                      { $$ = make_number($1); }
    | IDENTIFIER                { $$ = make_variable($1); }
    | expr '+' expr             { $$ = make_binary('+', $1, $3); }
    | expr '-' expr             { $$ = make_binary('-', $1, $3); }
    | expr '*' expr             { $$ = make_binary('*', $1, $3); }
    | expr '/' expr             { $$ = make_binary('/', $1, $3); }
    | '(' expr ')'              { $$ = $2; }
    | function_call             { $$ = $1; }
    ;

function_definition:
    DEF IDENTIFIER '(' param_list ')' function_body END {
        /* This is a simplified implementation */
        printf("Defined function: %s\n", $2);
    }
    ;

param_list:
    /* empty */
    | param_list_nonempty
    ;

param_list_nonempty:
    IDENTIFIER
    | param_list_nonempty ',' IDENTIFIER
    ;

function_body:
    statement_list
    ;

function_call:
    IDENTIFIER '(' arg_list ')' {
        yyerror("Function calls not fully implemented yet");
        $$ = make_number(0);
    }
    ;

arg_list:
    /* empty */
    | arg_list_nonempty
    ;

arg_list_nonempty:
    expr
    | arg_list_nonempty ',' expr
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(void) {
    FILE *archivo = fopen("entrada.txt", "r");
    if (!archivo) {
        perror("No se pudo abrir entrada.txt");
        return 1;
    }
    yyin = archivo;
    yyparse();
    fclose(archivo);
    return 0;
}
