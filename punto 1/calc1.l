%{
#include "calc1.tab.h"
#include <math.h>
#include <stdlib.h>
%}

%%

[ \t]+                             ; // Ignorar espacios y tabulaciones
"if"                               { return IF; }
"then"                             { return THEN; }
"else"                             { return ELSE; }
"fi"                               { return FI; }
"while"                            { return WHILE; }
"do"                               { return DO; }
"done"                             { return DONE; }

[0-9]+(\.[0-9]+)?                  { yylval.val = atof(yytext); return NUM; }
[a-z]                              { yylval.s = yytext[0]; return VAR; }

";"                                { return ';'; }
"="                                { return '='; }
[\n]                               { return '\n'; }
.                                  { return yytext[0]; }

%%

int yywrap(void) {
    return 1;
}
