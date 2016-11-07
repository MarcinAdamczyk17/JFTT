%{
#include <stdio.h>
int yywrap();
int yylex();

int newLines = 0;
int words = 0;
%}

WHITESPACE [ \t]

%%

^{WHITESPACE}*\n*    ;
{WHITESPACE}+$    ;
{WHITESPACE}+     {printf(" "); words++;}
\n                {printf("\n"); newLines++; words++;}
%%

int yywrap() {
  return 1;
}

int main() {
  yylex();
  printf("--------------\nLines: %d\nWords: %d\n", newLines, words);

  return 0;
}
