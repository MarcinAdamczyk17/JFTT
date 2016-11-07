%{
#include <stdio.h>
int yywrap();
int yylex();

char plus = 0;
%}
%x SINGLE_LINE
%x SINGLE_LINE_PLUS
%x MULTI_LINE
%x STRING
WS [\t ]

%%

\"                                  {BEGIN(STRING); printf("\"");}

<STRING>\"                          {BEGIN(INITIAL); printf("\"");}


{WS}*"\/\/".*                       {printf(" SINGLE_LINE_COMMENT ");}
^{WS}*"\/\/".*\\{WS}*$              {BEGIN(SINGLE_LINE_PLUS); printf("SINGLE_LINE_PLUS");}
<SINGLE_LINE_PLUS>.*\\{WS}*\n$        {printf("continuation of PLUS");}
<SINGLE_LINE_PLUS>\n$             {BEGIN(INITIAL); printf("CO DO CHUJA");}
<SINGLE_LINE>\n                     {BEGIN(INITIAL); printf("\n");}

%%

int yywrap() {
  return 1;
}

int main() {
  yylex();

  return 0;
}
