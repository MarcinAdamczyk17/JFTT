%{
  #include <stdio.h>
  #include <math.h>
  #include <string.h>
  #define YYDEBUG 1
  int yylex (void);
  void yyerror (char const *);
  void clearbuffers();
  void negate();
  int flag = 0;
  char output[100];
  char buffer[20];
%}

%token NUMBER
%left SUB ADD
%left MUL DIV MOD
%precedence NEG
%right POW
%token RB LB


%%

input:
  %empty
| input line
;

line:
  '\n'
| exp  '\n'           {if(!flag){printf("\n%s\nwynik:  %d\n\n\n-----------------------------\n",output, $1);} else printf("\n-------------------------\n"); flag = 0; clearbuffers();}
| exp error '\n'      {yyerror("error occured\n-----------------------------\n");}
;

exp:
  NUMBER              {$$ = $1;         sprintf(buffer, "%d ", $1); strcat(output, buffer);}
| exp ADD exp         {$$ = $1 + $3;    strcat(output, "+ ");}
| exp SUB exp         {$$ = $1 - $3;    strcat(output, "- ");}
| exp MUL exp         {$$ = $1 * $3;    strcat(output, "* ");}
| exp DIV exp
  {
    if($3 != 0){
      $$ = $1 / $3;
      printf(" / ");
      strcat(output, " / ");
    }
    else{
      yyerror("error: dividing by 0\n\n");
      flag = 1;
    }
  }
| exp MOD exp         {$$ = $1 % $3;    strcat(output, "% ");}
| SUB exp %prec NEG   {$$ = -$2;        negate();}
| exp POW exp         {$$ = pow($1, $3);strcat(output, "^ ");}
| LB exp RB           {$$ = $2;                       }
;
%%

#include <ctype.h>
#include <stdio.h>

void main(int argc, char** argv){
  yyparse();
}

void yyerror(char const *s){
  fprintf(stderr, "%s\n\n", s);
}

void clearbuffers(){
  int i;
  for(i = 0; i < 20; ++i){
    buffer[i] = NULL;
  }
  for(i = 0; i < 100; ++i){
    output[i] = NULL;
  }
}

void negate(){
  int i = strlen(output) - 2;
  while(output[i] > 47 && output[i] < 58){
    output[i + 1] = output[i];
    i--;
  }
  output[i+1] = '-';
  output[strlen(output)] = ' ';
}
