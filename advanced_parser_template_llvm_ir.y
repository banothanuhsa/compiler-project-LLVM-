%{
#include "head.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

int temp_counter = 1;
FILE *output_file;

typedef struct {
    char name[32];
    int reg;
    int is_alloc;
} Symbol;

Symbol symbol_table[100];
int symbol_count = 0;

int find_or_create_var(const char *name);
void emit(const char *fmt, ...);
void emit_alloca(int reg);
void emit_store(int var, int val);
void emit_load(int var);

extern int yylex(void);
extern FILE *yyin;
void yyerror(const char *s);
%}

%union {
    int ival;
    char *sval;
}

%token INT MAIN LBRACE RBRACE LPAREN RPAREN COMMA SEMICOLON ASSIGN
%token PLUS MINUS MUL DIV
%token <sval> ID
%token <ival> INT_CONST

%type <ival> expr term factor

%start program

%%

program:
    INT MAIN LPAREN RPAREN LBRACE declarations statements RBRACE {
        emit("ret i32 0");
    };

declarations:
    declarations declaration
    | declaration
    ;

declaration:
    INT var_list SEMICOLON
    ;

var_list:
    var_list COMMA ID {
        int reg = find_or_create_var($3);
        emit_alloca(reg);
    }
    | ID {
        int reg = find_or_create_var($1);
        emit_alloca(reg);
    }
    ;

statements:
    statements statement
    | statement
    ;

statement:
    ID ASSIGN expr SEMICOLON {
        int reg = find_or_create_var($1);
        emit_store(reg, $3);
    }
    ;

expr:
    expr PLUS term {
        emit("%%%d = add nsw i32 %%%d, %%%d", temp_counter, $1, $3);
        $$ = temp_counter++;
    }
    | expr MINUS term {
        emit("%%%d = sub nsw i32 %%%d, %%%d", temp_counter, $1, $3);
        $$ = temp_counter++;
    }
    | term { $$ = $1; }
    ;

term:
    term MUL factor {
        emit("%%%d = mul nsw i32 %%%d, %%%d", temp_counter, $1, $3);
        $$ = temp_counter++;
    }
    | term DIV factor {
        emit("%%%d = sdiv i32 %%%d, %%%d", temp_counter, $1, $3);
        $$ = temp_counter++;
    }
    | factor { $$ = $1; }
    ;

factor:
    ID {
        int reg = find_or_create_var($1);
        emit_load(reg);
        $$ = temp_counter - 1;
    }
    | INT_CONST {
        emit("%%%d = add i32 0, %d", temp_counter, $1);
        $$ = temp_counter++;
    }
    ;

%%

int find_or_create_var(const char *name) {
    for (int i = 0; i < symbol_count; ++i) {
        if (strcmp(symbol_table[i].name, name) == 0)
            return symbol_table[i].reg;
    }
    int reg = temp_counter++;
    strcpy(symbol_table[symbol_count].name, name);
    symbol_table[symbol_count].reg = reg;
    symbol_table[symbol_count].is_alloc = 0;
    symbol_count++;
    return reg;
}

void emit_alloca(int reg) {
    for (int i = 0; i < symbol_count; ++i) {
        if (symbol_table[i].reg == reg && !symbol_table[i].is_alloc) {
            emit("%%%d = alloca i32, align 4", reg);
            symbol_table[i].is_alloc = 1;
        }
    }
}

void emit_store(int var, int val) {
    emit("store i32 %%%d, i32* %%%d, align 4", val, var);
}

void emit_load(int var) {
    emit("%%%d = load i32, i32* %%%d, align 4", temp_counter, var);
    temp_counter++;
}

void emit(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vfprintf(output_file, fmt, args);
    fprintf(output_file, "\n");
    va_end(args);
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyin = stdin;
    output_file = fopen("output.ll", "w");

    fprintf(output_file, "define i32 @main() #0\n{\n");
    yyparse();
    emit("ret i32 0");
    fprintf(output_file, "\n}");

    fclose(output_file);
    return 0;
}
