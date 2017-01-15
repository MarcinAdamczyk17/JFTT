
%language "C++"

%locations
%define parser_class_name {cppcalc}
%debug
%code requires{
#define debugger 1
#define YYDEBUG 1
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
//using namespace cln;
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
void genADD(val* l, val* r);

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
| command							{if(debugger) cout << "reduce" << endl;	    }
;

command:
  identifier ASSIGN expression SC				{if(debugger) cout << "assign" << endl;	    $$ = genASSIGN($1);}
| IF condition THEN commands ELSE commands ENDIF		{if(debugger) cout << "if" << endl;	    }
| WHILE condition DO commands ENDWHILE				{if(debugger) cout << "while" << endl;	    $$ = genWHILE($2, $4);}
| FOR pidentifier FROM value TO value DO commands ENDFOR	{if(debugger) cout << "for to" << endl;	    }
| FOR pidentifier FROM value DOWNTO value DO commands ENDFOR	{if(debugger) cout << "for down" << endl;   }
| READ identifier SC						{if(debugger) cout << "read" << endl;	    $$ = genREAD($2);}
| WRITE value SC						{if(debugger) cout << "write" << endl;	    $$ = genWRITE($2);}
| SKIP SC							{if(debugger) cout << "skip" << endl;	    }
;

expression:
  value								{genNoOP($1);}
| value ADD value						{genADD($1, $3);}
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
  pidentifier							{$$ = getVariable($1); if($$ == nullptr || $$->isArray){cout << "error: is array\n"; return 0;}}
| pidentifier LEFT_BRACKET pidentifier RIGHT_BRACKET		{$$ = getArrayVariable($1, getVariableValue($3));}
| pidentifier LEFT_BRACKET num RIGHT_BRACKET			{$$ = getArrayVariable($1, $3);}
;

%%
#include <cstring>
#include <string.h>
#include <vector>
#include <iostream>
#include <fstream>

using namespace std;
using namespace cln;
//typedef basic_string<char> string;

vector<var*> variablesContainer;

vector<vector<string>> codes;
int registers [5] = {0,0,0,0,0};
#include "variableOperations.h"

int genASSIGN(var* variable){
    cout << "ass " << variable->name << endl;
    variable->isInitialized = true;
    vector<string> code;
    for(int i = 0; i < codes[codes.size()-1].size(); ++i){
	code.push_back(codes[codes.size()-1][i]);
    }
    setRegister(0, variable->memoryLocation, code);
    cout << "mid ass " << variable->name << endl;

    code.push_back("STORE 1");
    codes.push_back(code);
    cout << "end ass " << variable->name << endl;
    return codes.size()-1;
}

int genWHILE(cond* condition, int pos){

    vector<string> code;

    string op = condition->op;
    val* v1 = condition->val1;
    val* v2 = condition->val2;
    //cout << "gen while v1 " << endl;
    //cout << "gen while v2 " << v2->value << endl;
    if(!op.compare("EQ")){
	//cout << "eq" << endl;
    }
    else if (!op.compare("DI")) {
	//cout << "di" << endl;
    }
    else if (!op.compare("ST")) {
	//cout << "st" << endl;
    }
    else if (!op.compare("BT")) {
	//cout << "bt" << endl;
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
	code.push_back("JZERO 1 " + to_string(codes[pos].size()+2));
	//cout << endl << endl;
	//printVec(code);
    }
    else if (!op.compare("SE")) {
	//cout << "se" << endl;
    }
    else if (!op.compare("BE")) {
	//cout << "be" << endl;
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
    variable->isInitialized = true;
    vector<string> code;
    code.push_back("GET 1");
    setRegister(0, variable->memoryLocation, code);
    code.push_back("STORE 1");
    codes.push_back(code);
    return codes.size() - 1;
}

int genWRITE(val* value){
    cout << "wr" << endl;
    vector<string> code;

    if(value->variable != nullptr){
	if(!value->variable->isInitialized){
	    cout << "ERROR: variable '" << value->variable->name << "' not initialized" << endl;
	}
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
	if(!value->variable->isInitialized){
	    cout << "ERROR: variable '" << value->variable->name << "' not initialized" << endl;
	}
	setRegister(0, value->variable->memoryLocation, code);
	code.push_back("LOAD 1");
    }
    else{
	setRegister(1, value->value, code);
    }
    codes.push_back(code);
}

void genADD(val* l, val* r){
    vector<string> code;

    if(l->variable != nullptr){
	setRegister(0, l->variable->memoryLocation, code);
	code.push_back("LOAD 1");
    }
    else{
	setRegister(1, l->value, code);
    }

    if(r->variable != nullptr){
	setRegister(0, r->variable->memoryLocation, code);
	code.push_back("ADD 1");
    }
    else{
	setRegister(2, r->value, code);
	setRegister(0, variablesContainer.size(), code);
	code.push_back("STORE 2");
	code.push_back("ADD 1");
    }

    codes.push_back(code);
}

void setRegister(int reg, int value, vector<string> &code){
    cout << "sr" << endl;

    code.push_back("ZERO " + to_string(reg));
    cout << "sr 2" << endl;
    bool firstShift = true;
    registers[reg] = 0;

    int i;
    int bits[32];

    for (i = 0; i < 32; ++i) {
	bits[31-i] = value & (1 << i) ? 1 : 0;
    }
    i = 0;
    while(!bits[i]) ++i;
    cout << "sr 3" << endl;
    for (i; i < 32; ++i) {
	if(bits[i]){
	    if(!firstShift){
		code.push_back("SHL " + to_string(reg));
	    }
	    firstShift = false;
	    code.push_back("INC " + to_string(reg));
	}
	else{
	    code.push_back("SHL " + to_string(reg));
	}

    }
    cout << "end sr" << endl;
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
    //cout << "nc" << endl;
    if(val1->variable != nullptr && !val1->variable->isInitialized){
	cout << "ERROR: variable '" << val1->variable->name << "' not initialized" << endl;
    }
    if(val2->variable != nullptr && !val2->variable->isInitialized){
	cout << "ERROR: variable '" << val2->variable->name << "' not initialized" << endl;
    }

    cond* condition = (cond*)malloc(sizeof(cond));

    condition->val1 = val1;
//cout << "1" << endl;
    condition->op = op;
//out << "2" << endl;
    condition->val2 = val2;
//cout << "3" << endl;
    return condition;
}

int concatenateCodes(int v1, int v2){
    cout << "cc" << endl;
    vector<string> code;
    code.reserve(codes[v1].size() + codes[v2].size());
    code.insert( code.end(), codes[v1].begin(), codes[v1].end() );
    code.insert( code.end(), codes[v2].begin(), codes[v2].end() );

    codes.push_back(code);
    cout << "cc - end" << endl;
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

    bool counter = 0;
    cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n";
    yy::cppcalc parser;
    int v = parser.parse();
    int k = 0;
    int pos = codes.size()-1;

    ofstream myfile;
    myfile.open ("output.txt");
    vector<string> result = codes[pos];

    string delim = " ";
    for(int j = 0; j < result.size(); ++j){
	if(counter) cout << k << " ";
	if(k < 10){
	   if(counter) cout << " ";
	}
	if(!result[j].substr(0, result[j].find(delim)).compare("JZERO")){
	    int offset = stoi(result[j].substr(result[j].find(delim)+2, result[j].length()));
	    result[j] = "JZERO 1 " + to_string(k + offset);
	}
	if(!result[j].substr(0, result[j].find(delim)).compare("JODD")){
	    int offset = stoi(result[j].substr(result[j].find(delim)+2, result[j].length()));
	    result[j] = "JODD 1 " + to_string(k + offset);
	}
	if(!result[j].substr(0, result[j].find(delim)).compare("JUMP")){
	    int offset = stoi(result[j].substr(result[j].find(delim), result[j].length()));
	    result[j] = "JUMP " + to_string(k + offset);
	}
	//cout << result[j] << endl;
	myfile << result[j] << endl;
	++k;
    }

    {cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";}
    myfile.close();
    return v;
}

namespace yy {
  void cppcalc::error(location const &loc, const std::string& s) {
    std::cerr << "error at " << loc << ": " << s << std::endl;
  }
}
