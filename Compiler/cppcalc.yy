
%language "C++"

%locations
%define parser_class_name {cppcalc}
%debug
%code requires {
    #define DBG 1
    #define YYDEBUG 1

    #include <stdio.h>
    #include <iostream>
    #include <cstring>
    #include <string>
    #include <string.h>
    #include <vector>

    #include "functions.h"
    #include "types.h"

    using namespace std;

}

%union {
    string* sval;
    int ival;
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
%type <ival> value
%type <ival> identifier
%type <ival> condition expression 

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
    VAR vdeclarations START commands END                                  {if(DBG) cout << "program" << endl; endThisShit();}
;

vdeclarations:
    vdeclarations pidentifier	                                          {if(DBG) cout << "declare variable" << endl; declareVariable($2);}
|   vdeclarations pidentifier LEFT_BRACKET num RIGHT_BRACKET              {if(DBG) cout << "delcare array" << endl; declareArray($2, $4);}
|
;

commands:
    commands command                                                      {}
|   command                                                               {}
;

command:
    identifier ASSIGN expression SC                                       {if(DBG) cout << "assign" << endl; $$ = gen_Assign($1, $3);}
|   IF condition THEN commands ELSE commands ENDIF                        {if(DBG) cout << "if" << endl;}
|   WHILE condition DO commands ENDWHILE                                  {if(DBG) cout << "while" << endl;}
|   FOR pidentifier FROM value TO value DO commands ENDFOR                {if(DBG) cout << "for to" << endl;}
|   FOR pidentifier FROM value DOWNTO value DO commands ENDFOR            {if(DBG) cout << "for downto" << endl;}
|   READ identifier SC                                                    {if(DBG) cout << "read" << endl;}
|   WRITE value SC                                                        {if(DBG) cout << "write" << endl;}
|   SKIP SC                                                               {if(DBG) cout << "skip" << endl;}
;

expression:
    value                                                                 {if(DBG) cout << "value" << endl;}
|   value ADD value                                                       {if(DBG) cout << "add" << endl; $$ = gen_Add($1, $3);}
|   value SUB value                                                       {if(DBG) cout << "sub" << endl;}
|   value MULT value                                                      {if(DBG) cout << "mult" << endl;}
|   value DIV value                                                       {if(DBG) cout << "div" << endl;}
|   value MOD value                                                       {if(DBG) cout << "mod" << endl;}
;

condition:
    value EQUAL value                                                     {if(DBG) cout << "eq" << endl;}
|   value DIFFERENT value                                                 {if(DBG) cout << "neq" << endl;}
|   value SMALLER_THAN value                                              {if(DBG) cout << "st" << endl;}
|   value BIGGER_THAN value                                               {if(DBG) cout << "bt" << endl;}
|   value SMALLER_THAN_OR_EQUAL value                                     {if(DBG) cout << "set" << endl;}
|   value BIGGER_THAN_OR_EQUAL value                                      {if(DBG) cout << "bet" << endl;}
;

value:
    num                                                                   {if(DBG) cout << "num " << $1 << " "; $$ = gen_ConstNumber($1);}
|   identifier                                                            {if(DBG) cout << "id" << endl;}
;

identifier:
    pidentifier                                                           {if(DBG) cout << "pid " << endl; $$ = gen_Pidentifier($1);}
|   pidentifier LEFT_BRACKET pidentifier RIGHT_BRACKET                    {if(DBG) cout << "array pid " << endl; $$ = gen_ArrayPid($1, $3);}
|   pidentifier LEFT_BRACKET num RIGHT_BRACKET                            {if(DBG) cout << "array num " << endl; $$ = gen_ArrayConst($1, $3);}
;

%%

#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <vector>

#include "types.h"
#include "functions.h"

#define CODE_DBG 1
using namespace std;

int memory_used = 10;
vector<vector<string>> codeFragments;
std::map<string, std::shared_ptr<value_t>> variables;

void endThisShit()
{
    // cout << __FUNCTION__ << endl;
    // for(vector<string> code : codeFragments)
    // {
    // 	for(string s : code){
    // 		cout << s << endl;
    // 	}
    // }
}

int gen_Assign(int v1, int v2)
{
	cout << __FUNCTION__ << endl;	
}

int gen_Add(int v1, int v2)
{
	cout << __FUNCTION__ << endl;	
}

int gen_ConstNumber(int num)
{
    cout << __FUNCTION__ << endl;
    vector<string> code;

    setRegister(code, num);
    
    if(CODE_DBG)
    { 
    	code.push_back("\n");
    	printVector(code);
	}

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_Pidentifier(std::string* name)
{
    cout << __FUNCTION__ << *name << endl;
	vector<string> code;

	if(variables.find(*name) == variables.end())
    {
      	cerr << "ERROR: variable \'" << *name << "\' doesn't exist" << endl;
      	exit(0);
    }
    else
    {
    	if(variables[*name]->isArray){
    		cerr << "ERROR: variable \'" << *name << "\' is array type" << endl;
    		exit(0);
    	}	

    	setRegister(code, variables[*name]->memory_position);
    }
    if(CODE_DBG)
    { 
    	code.push_back("\n");
    	printVector(code);
	}

    codeFragments.push_back(code);
    return codeFragments.size() - 1;

}

int gen_ArrayConst(std::string* name, int position)
{
    cout << __FUNCTION__ << endl;
	vector<string> code;

	if(variables.find(*name) == variables.end())
    {
      	cerr << "ERROR: variable \'" << *name << "\' doesn't exist" << endl;
      	exit(0);
    }
    else
    {
    	if(!variables[*name]->isArray) 
    	{
    		cerr << "ERROR: variable \'" << *name << "\' is not array type" << endl;
    		exit(0);
    	}
    	if(variables[*name]->capacity <= position) 
    	{
			cerr << "ERROR: variable \'" << *name << "\' array out of bounds pseudo-exception" << endl;
    		exit(0);
    	}	

    	setRegister(code, variables[*name]->memory_position + position);
    }
    if(CODE_DBG)
    { 
    	code.push_back("\n");
    	printVector(code);
	}

    codeFragments.push_back(code);
    return codeFragments.size() - 1;

}

int gen_ArrayPid(std::string* arrayName, std::string* positionPid)
{
    cout << __FUNCTION__ << endl;
	vector<string> code;

	if(variables.find(*arrayName) == variables.end())
    {
      	cerr << "ERROR: variable \'" << *arrayName << "\' doesn't exist" << endl;
      	exit(0);
    }
    if(variables.find(*positionPid) == variables.end())
    {
      	cerr << "ERROR: variable \'" << *positionPid << "\' doesn't exist" << endl;
      	exit(0);
    }
    else
    {
    	if(!variables[*arrayName]->isArray) 
    	{
    		cerr << "ERROR: variable \'" << *arrayName << "\' is not array type" << endl;
    		exit(0);
    	}
    	if(variables[*positionPid]->isArray) 
    	{
    		cerr << "ERROR: variable \'" << *positionPid << "\' is array type" << endl;
    		exit(0);
    	}
    	setRegister(code, variables[*arrayName]->memory_position);
    	code.push_back("ADD " + to_string(variables[*positionPid]->memory_position));
    }
    if(CODE_DBG)
    { 
    	code.push_back("\n");
    	printVector(code);
	}
    
    codeFragments.push_back(code);
	return codeFragments.size() - 1;
}

void declareVariable(string* name)
{
    cout << __FUNCTION__ << endl;
    if(variables.find(*name) == variables.end())
    {
        variables[*name] = make_shared<value_t>(0, 0, memory_used, *name);
        memory_used++;

        if(CODE_DBG) cout << "memory usage: " << to_string(memory_used) << endl;

    }
    else
    {
      cerr << "ERROR: variable already exists" << endl;
    }
}

void declareArray(std::string* name, int capacity)
{
    cout << __FUNCTION__ << endl;
	if(variables.find(*name) == variables.end())
	{
        variables[*name] = make_shared<value_t>(1, 0, memory_used, *name);
        variables[*name]->capacity = capacity;
        memory_used += capacity;

        if(CODE_DBG) cout << "memory usage: " << to_string(memory_used) << endl;
    }
    else
    {
      cerr << "ERROR: variable already exists" << endl;
    }
}

void setRegister(vector<string>& code, int value)
{
	cout << __FUNCTION__ << endl;

    code.push_back("ZERO");

    bool firstShift = true;

    int i;
    int bits[32];
    for (i = 0; i < 32; ++i) {
		bits[31-i] = value & (1 << i) ? 1 : 0;
    }
    i = 0;
    
    while(!bits[i]) ++i;

    for (i; i < 32; ++i) 
    {
		if(bits[i])
		{
		    if(!firstShift)
		    {
				code.push_back("SHL");
		    }
		    code.push_back("INC");
		    firstShift = false;
		}
		else
		{
		    code.push_back("SHL");
		}
    }
}

void printVector(std::vector<string>& v)
{
	for(string s : v){
    	cout << s << endl;
    }
}

int main() 
{
  	cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n";
  	yy::cppcalc parser;
  	int v = parser.parse();

  	ofstream myfile;
  	myfile.open ("output.txt");


    cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";

    for(vector<string> code : codeFragments)
    {
        for(string s : code)
        {
            myfile << s << endl;
        }
    }
        
	myfile.close();

  	return v;
}

namespace yy {
    void cppcalc::error(location const &loc, const std::string& s) {
        std::cerr << "error at " << loc << ": " << s << std::endl;
    }
}
