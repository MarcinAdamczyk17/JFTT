%{
#include <stdio.h>
#include <math.h>
#include "Stack.h"

int yywrap();
int yylex();
void update();
void error_forbidden_char(char c);
void calculate(char* operand);

List* list;
int numbers = 0;
int operands = 0;
char forbidden;
%}
NUMBER  "-"?[0-9]+
OP      [\+\-\*\/\^\%]
ERROR    [^0-9\+\-\*\/\^\% ]
WS [\t ]

%x START
%x END
%x ERROR
%%
\n                   {printf("\n"); update(); printf("\n-------------------------------------------\n");}
{ERROR}              {BEGIN(ERROR); printf("%s", yytext); forbidden = *yytext;}
<ERROR>.*\n          {printf("%s", yytext); error_forbidden_char(forbidden); BEGIN(INITIAL); printf("\n-------------------------------------------\n");}
{NUMBER}             {printf("%s", yytext); ++numbers; enqueueHead(list, atoi(yytext));}
{OP}                 {printf("%s", yytext); ++operands; calculate(yytext);}
%%

int yywrap() {
  return 1;
}

void update(){
  //printf("numbers: %d      operands: %d\n", numbers, operands);
  if(numbers - operands > 1){
    printf("ERROR: TOO MANY NUMBERS\n");
    return;
  }
  else if(numbers - operands < 1){
    printf("ERROR: TOO MANY OPERANDS\n");
    return;
  }


    if(list->size == 1){
      printf("\nresult: %d\n", getValue(list, 1));
    }

  empty(list);

  operands = 0;
  numbers = 0;
}

void error_forbidden_char(char c){
  operands = 0;
  numbers = 0;
  printf("ERROR: FORBIDDEN CHARACTER \"%s\"\n", &c);
}

void calculate(char* op){
  if(list->size < 2){
    return;
  }

  int a = dequeueHead(list);
  int b = dequeueHead(list);

  switch(*op){
    case '+': enqueueHead(list, a+b); break;
    case '-': enqueueHead(list, b-a); break;
    case '*': enqueueHead(list, a*b); break;
    case '/':
      if(a == 0){
        printf("\nERROR DIVIDING BY 0");
        break;
      }
      enqueueHead(list, b/a);
      break;
    case '^': enqueueHead(list, (int)pow((double)b,(double)a)); break;
    case '%': enqueueHead(list, b%a); break;
    default: printf("idk\n");
  }


}

int main() {
  list = create();

  yylex();


  return 0;
}
