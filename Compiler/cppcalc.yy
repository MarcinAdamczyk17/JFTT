
%language "C++"

%locations
%define parser_class_name {cppcalc}

%code requires{

#include <cln/cln.h>
#include <cln/number.h>
#include <stdio.h>
#include <iostream>
#include <cstring>
#include <string>
#include <string.h>
#include <vector>

//#include "variable.h"
using namespace std;
using namespace cln;
#include "variable.h"
void declareVariable(char* name);
void declareArray(char* name, int size);
bool checkIfAlreadyDeclared(char* name);
bool checkIfInitialized(char* name);
void initializeVariable(char* name, int value);
int getVariableValue(char* name);
int getArrayValue(char* name, int position);
var* getVariable(char* name);
var* getArrayVariable(char* name, int position);
int getArrayVariableValue(char* name, int position);
void initializeArrayVariable(char* name, int position, int value);

vector<string> genREAD(var* variable);
void setRegister(int reg, int value);

}

%union {
  char* sval;
  int ival;
  var* variable;
  char* code;
  vector<string>* codeVector;
}


%token VAR
%token START
%token END
%token IF
%token THEN
%token ELSE
%token ENDIF
%token WHILE
%token DO
%token ENDWHILE
%token FOR
%token FROM
%token TO
%token DOWNTO
%token ENDFOR
%token READ
%token WRITE
%token SKIP
%token SC
%token ASSIGN
%token EQUAL
%token DIFFERENT
%token SMALLER_THAN
%token BIGGER_THAN
%token SMALLER_THAN_OR_EQUAL
%token BIGGER_THAN_OR_EQUAL
%token pidentifier
%token num

%type <sval> pidentifier
%type <ival> num value expression
%type <variable> identifier

%left SUB ADD
%left MULT DIV MOD
%precedence NEG
%right POW
%token RIGHT_BRACKET LEFT_BRACKET
%{
extern int yylex(yy::cppcalc::semantic_type *yylval, yy::cppcalc::location_type* yylloc);
%}
%initial-action {
// Filename for locations here
//@$.begin.filename = @$.end.filename = new std::string("stdin");
}
%%


program:
  VAR vdeclarations START commands END
;

vdeclarations:
  vdeclarations pidentifier					{declareVariable($2); cout << $2 << endl;}
| vdeclarations pidentifier LEFT_BRACKET num RIGHT_BRACKET	{declareArray($2, $4); cout << $2 << "[" << $4 << "]" << endl;}
|
;

commands:
  commands command
| command
;

command:
  identifier ASSIGN expression SC				{$1->value = $3;}
| IF condition THEN commands ELSE commands ENDIF
| WHILE condition DO commands ENDWHILE
| FOR pidentifier FROM value TO value DO commands ENDFOR
| FOR pidentifier FROM value DOWNTO value DO commands ENDFOR
| READ identifier SC	{genREAD($2);}
| WRITE value SC
| SKIP SC
;

expression:
  value
| value ADD value
| value SUB value
| value MULT value
| value DIV value
| value MOD value
;

condition:
  value EQUAL value
| value DIFFERENT value
| value SMALLER_THAN value
| value BIGGER_THAN value
| value SMALLER_THAN_OR_EQUAL value
| value BIGGER_THAN_OR_EQUAL value
;

value:
  num
| identifier							{$$ = $1->value;}
;

identifier:
  pidentifier							{$$ = getVariable($1); if($$ == nullptr) return 0;}
| pidentifier LEFT_BRACKET pidentifier RIGHT_BRACKET		{$$ = getArrayVariable($1, getVariableValue($3));}
| pidentifier LEFT_BRACKET num RIGHT_BRACKET			{$$ = getArrayVariable($1, $3);}
;

%%
#include <cstring>
#include <string.h>
#include <vector>

using namespace std;
using namespace cln;
//typedef basic_string<char> string;

vector<var*> variablesContainer;
vector<string> code;
int registers [5] = {0,0,0,0,0};
#include "variableOperations.h"

vector<string> genREAD(var* variable){
    code.push_back("GET 1");
    setRegister(0, variable->memoryLocation);
    code.push_back("STORE 1");

    return code;
}

void setRegister(int reg, int value){
    for(int i = 0; i < value - registers[reg]; ++i){
	 code.push_back("INC " + to_string(reg));
    }
    registers[reg] = value;

}


void test(){
    cl_I number = "1844674407370955162705479678643152978954540";

    cout << sizeof(number) << endl;

    cout << number << endl;

}

int main() {
    //test();

    cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";
    yy::cppcalc parser;
    int v = parser.parse();

    for(int i = 0; i < code.size(); ++i){
	cout << code[i] << endl;
    }
    return v;
}


namespace yy {
  void cppcalc::error(location const &loc, const std::string& s) {
    std::cerr << "error at " << loc << ": " << s << std::endl;
  }
}
