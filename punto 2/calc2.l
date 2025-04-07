%{
#include "calc2.tab.h"
#include <stdlib.h>

/* Remove the redundant struct definition */
%}

%%

[0-9]+(\.[0-9]+)?   { yylval.dval = atof(yytext); return NUMBER; }
[ \t]               ;
\n                  return '\n';
"+"                 return '+';
"-"                 return '-';
"*"                 return '*';
"/"                 return '/';
"("                 return '(';
")"                 return ')';

.                   { return yytext[0]; }

%%

int yywrap() {
    return 1;
}
