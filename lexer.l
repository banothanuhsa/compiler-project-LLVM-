%{
#include "advanced_parser_template_llvm_ir.tab.h"
#include <stdio.h>
#include <stdlib.h>
%}

%%

"int"                { return INT; }
"main"               { return MAIN; }
"{"                  { return LBRACE; }
"}"                  { return RBRACE; }
"("                  { return LPAREN; }
")"                  { return RPAREN; }
","                  { return COMMA; }
";"                  { return SEMICOLON; }
"="                  { return ASSIGN; }
"+"                  { return PLUS; }
"-"                  { return MINUS; }
"*"                  { return MUL; }
"/"                  { return DIV; }
[0-9]+               { yylval.ival = atoi(yytext); return INT_CONST; }
[a-zA-Z][a-zA-Z0-9]* { yylval.sval = strdup(yytext); return ID; }
[ \t\n\r]+           { /* Skip whitespace */ }
.                    { /* Handle any unmatched characters */ }

%%

int yywrap() {
    return 1;
}
