%{
#include "rpcalc.h"
#include <stdlib.h>
#include <stdio.h>


%}
WHITESPACE [ \t]
%x COMMENT
%%

\\{WHITESPACE}*\n                {}

"#"                     BEGIN(COMMENT);
<COMMENT>\\\n
<COMMENT>\n             BEGIN(INITIAL);
<COMMENT>[^\\]|[^\n]

"+"			            {printf("+ ");return ADD;}
"-"		           	  {printf("- ");return SUB;}
"*"					       	{printf("* ");return MUL;}
"/"			            {printf("/ ");return DIV;}
"^"			            {printf("^ ");return POW;}
[0-9]+		         	{yylval = atoi(yytext); printf("%d ", yylval);return NUMBER;}
"\("                {printf("( ");return LB;}
"\)"                {printf(") ");return RB;}
"%"                 {printf("% ");return MOD;}
\n			            {return '\n';}
[ \t]               {}
.             		  { printf("Mystery character %c\n", *yytext); }

%%
