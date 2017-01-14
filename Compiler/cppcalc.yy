
%language "C++"

%locations
%define parser_class_name {cppcalc}

%code requires{
#define debugger 0
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

int genASSIGN(var *variable);
int genWHILE(cond *codition, int pos);
int genREAD(var* variable);
int genWRITE(val* value);

void genNoOP(val* value);
void genADD(int l, int r);


void setRegister(int reg, int value, vector<string> &code);

val* newValue(var* variable);
val* newValue(int value);
cond* newCondition(val* val1, string op, val* val2);

void printVec(vector<string> &v);
int concatenateCodes(int v1, int v2);
void endThisShit();
}

%union {
  char* sval;
  int ival;
  var* variable;
  val* value;
  cond* condition;
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
%type <ival> num command commands
%type <value> value
%type <variable> identifier
%type <condition> condition

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
  VAR vdeclarations START commands END				{endThisShit();}
;

vdeclarations:
  vdeclarations pidentifier					{declareVariable($2);}
| vdeclarations pidentifier LEFT_BRACKET num RIGHT_BRACKET	{declareArray($2, $4);}
|
;

commands:
  commands command						{if(debugger) cout << "continue" << endl;   $$ = concatenateCodes($1, $2);}
| command							{if(debugger) cout << "reduce" << endl;	    $$ = $1;}
;

command:
  identifier ASSIGN expression SC				{if(debugger) cout << "assign" << endl;	    $$ = genASSIGN($1);}
| IF condition THEN commands ELSE commands ENDIF		{if(debugger) cout << "if" << endl;	    }
| WHILE condition DO commands ENDWHILE				{if(1) cout << "while" << $4 << endl;	    $$ = genWHILE($2, $4);}
| FOR pidentifier FROM value TO value DO commands ENDFOR	{if(debugger) cout << "for to" << endl;	    }
| FOR pidentifier FROM value DOWNTO value DO commands ENDFOR	{if(debugger) cout << "for down" << endl;   }
| READ identifier SC						{if(debugger) cout << "read" << endl;	    $$ = genREAD($2);}
| WRITE value SC						{if(debugger) cout << "write" << endl;	    $$ = genWRITE($2);}
| SKIP SC							{if(debugger) cout << "skip" << endl;	    }
;

expression:
  value								{genNoOP($1);}
| value ADD value
| value SUB value
| value MULT value
| value DIV value
| value MOD value
;

condition:
  value EQUAL value						{$$ = newCondition($1, "EQ", $3);}
| value DIFFERENT value						{$$ = newCondition($1, "DI", $3);}
| value SMALLER_THAN value					{$$ = newCondition($1, "ST", $3);}
| value BIGGER_THAN value					{$$ = newCondition($1, "BT", $3);}
| value SMALLER_THAN_OR_EQUAL value				{$$ = newCondition($1, "SE", $3);}
| value BIGGER_THAN_OR_EQUAL value				{$$ = newCondition($1, "BE", $3);}
;

value:
  num								{$$ = newValue($1);}
| identifier							{$$ = newValue($1);}
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
vector<vector<string>> codes;
int registers [5] = {0,0,0,0,0};
#include "variableOperations.h"

int genASSIGN(var* variable){
    vector<string> code = codes[codes.size()-1];
    setRegister(0, variable->memoryLocation, code);
    code.push_back("STORE 1");
    codes[codes.size()-1] = code;
    return codes.size()-1;
}

int genWHILE(cond* condition, int pos){

    vector<string> code;
    string op = condition->op;
    val* v1 = condition->val1;
    val* v2 = condition->val2;
    //cout << "gen while v1 " << v1->variable->value << endl;
    //cout << "gen while v2 " << v2->variable->value << endl;
    if(!op.compare("EQ")){
	cout << "eq" << endl;
    }
    else if (!op.compare("DI")) {
	cout << "di" << endl;
    }
    else if (!op.compare("ST")) {
	cout << "st" << endl;
    }
    else if (!op.compare("BT")) {
	cout << "bt" << endl;
	if(v1->variable != nullptr){
	    setRegister(0, v1->variable->memoryLocation, code);
	    code.push_back("LOAD 1");
	}
	else{
	    setRegister(1, v1->value, code);
	}

	if(v2->variable != nullptr){
	    setRegister(0, v2->variable->memoryLocation, code);
	    code.push_back("SUB 1");
	}
	else{
	    setRegister(0, variablesContainer.size(), code);
	    setRegister(2, v2->value, code);
	    code.push_back("STORE 2");
	    code.push_back("SUB 1");
	}
	code.push_back("JZERO " + to_string(codes[pos].size()+2));
	//cout << endl << endl;
	//printVec(code);
    }
    else if (!op.compare("SE")) {
	cout << "se" << endl;
    }
    else if (!op.compare("BE")) {
	cout << "be" << endl;
    }

    vector<string> result;
    result.reserve( code.size() + codes[pos].size() );
    result.insert( result.end(), code.begin(), code.end() );
    result.insert( result.end(), codes[pos].begin(), codes[pos].end() );
    result.push_back("JUMP -" + to_string(codes[pos].size() + code.size()));
    codes.push_back(result);
    return codes.size()-1;
}

int genREAD(var* variable){
    vector<string> code;
    code.push_back("GET 1");
    setRegister(0, variable->memoryLocation, code);
    code.push_back("STORE 1");
    codes.push_back(code);
    return codes.size() - 1;
}

int genWRITE(val* value){
    vector<string> code;

    if(value->variable != nullptr){
	setRegister(0, value->variable->memoryLocation, code);
	code.push_back("LOAD 1");
	code.push_back("PUT 1");
    }
    else{
	setRegister(1, value->value, code);
	code.push_back("PUT 1");
    }
    codes.push_back(code);

    return codes.size() - 1;
}

void genNoOP(val* value){
    vector<string> code;

    if(value->variable != nullptr){
	setRegister(0, value->variable->memoryLocation, code);
	code.push_back("LOAD 1");
    }
    else{
	setRegister(1, value->value, code);
    }
    codes.push_back(code);
}

void genADD(int l, int r){}

void setRegister(int reg, int value, vector<string> &code){
    code.push_back("ZERO " + to_string(reg));
    registers[reg] = 0;

    for(int i = 0; i < value; ++i){
	 code.push_back("INC " + to_string(reg));
    }
    registers[reg] = value;
}

val* newValue(var* variable){
    val* value = (val*)malloc(sizeof(val));
    value->variable = variable;

    return value;
}

val* newValue(int number){
    val* value = (val*)malloc(sizeof(val));
    value->variable = nullptr;
    value->value = number;

    return value;
}

cond* newCondition(val* val1, string op, val* val2){
    cond* condition = (cond*)malloc(sizeof(cond));
    condition->val1 = val1;
    condition->op = op;
    condition->val2 = val2;
    return condition;
}

int concatenateCodes(int v1, int v2){
    cout << v1 << "  " << v2 << endl;
    vector<string> code;
    code.reserve(codes[v1].size() + codes[v2].size());
    code.insert( code.end(), codes[v1].begin(), codes[v1].end() );
    code.insert( code.end(), codes[v2].begin(), codes[v2].end() );

    codes.push_back(code);
    return codes.size()-1;
}



void endThisShit(){
    codes[codes.size()-1].push_back("HALT");

}

void printVec(vector<string> &v){
    for(int i = 0; i < v.size(); ++i){
	cout << v[i] << endl;
    }
}

void printVec(int i){
    vector<string> v = codes[i];
    for(int i = 0; i < v.size(); ++i){
	cout << v[i] << endl;
    }
}

int main() {
    //test();

    cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n";
    yy::cppcalc parser;
    int v = parser.parse();
    int k = 0;
    int pos = codes.size()-1;
    for(int j = 0; j < codes[pos].size(); ++j){
	//cout << k << " ";
	if(k < 10){
	   // cout << " ";
	}
	cout << codes[pos][j] << endl;
	++k;
    }
    /*
    for(int i = 0; i < codes.size(); ++i){
	for(int j = 0; j < codes[i].size(); ++j){
	    //cout << k << " ";
	    if(k < 10){
		//cout << " ";
	    }
	    cout << codes[i][j] << endl;
	    ++k;
	}
	cout << endl;
    }
    */

    {cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";}
    return v;
}


namespace yy {
  void cppcalc::error(location const &loc, const std::string& s) {
    std::cerr << "error at " << loc << ": " << s << std::endl;
  }
}
