
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
    VAR vdeclarations START commands END                                  {if(DBG) cout << "program" << endl; endThisShit($4);}
;

vdeclarations:
    vdeclarations pidentifier	                                          {if(DBG) cout << "declare variable" << endl; declareVariable($2);}
|   vdeclarations pidentifier LEFT_BRACKET num RIGHT_BRACKET              {if(DBG) cout << "delcare array" << endl; declareArray($2, $4);}
|
;

commands:
    commands command                                                      {$$ = concatenate_codes($1, $2);}
|   command                                                               {}
;

command:
    identifier ASSIGN expression SC                                       {if(DBG) cout << "assign" << endl; $$ = gen_commnad_assign($1, $3);}
|   IF condition THEN commands ELSE commands ENDIF                        {if(DBG) cout << "if" << endl; $$ = gen_command_ifelse($2, $4, $6);}
|   IF condition THEN commands ENDIF                                      {if(DBG) cout << "if" << endl; $$ = gen_command_if($2, $4);}
|   WHILE condition DO commands ENDWHILE                                  {if(DBG) cout << "while" << endl; $$ = gen_command_while($2, $4);}
|   FOR pidentifier FROM value TO value DO commands ENDFOR                {if(DBG) cout << "for to" << endl;}
|   FOR pidentifier FROM value DOWNTO value DO commands ENDFOR            {if(DBG) cout << "for downto" << endl;}
|   READ identifier SC                                                    {if(DBG) cout << "read" << endl;}
|   WRITE value SC                                                        {if(DBG) cout << "write" << endl; $$ = gen_command_write($2);}
|   SKIP SC                                                               {if(DBG) cout << "skip" << endl;}
;

expression:
    value                                                                 {if(DBG) cout << "value" << endl; $$ = gen_expr_value($1);}
|   value ADD value                                                       {if(DBG) cout << "add" << endl; $$ = gen_expr_add($1, $3);}
|   value SUB value                                                       {if(DBG) cout << "sub" << endl; $$ = gen_expr_sub($1, $3);}
|   value MULT value                                                      {if(DBG) cout << "mult" << endl; $$ = gen_expr_mult($1, $3);}
|   value DIV value                                                       {if(DBG) cout << "div" << endl; $$ = gen_expr_div($1, $3);}
|   value MOD value                                                       {if(DBG) cout << "mod" << endl; $$ = gen_expr_mod($1, $3);}
;

condition:
    value EQUAL value                                                     {if(DBG) cout << "eq" << endl; $$ = gen_condition_equal($1, $3);}
|   value DIFFERENT value                                                 {if(DBG) cout << "neq" << endl; $$ = gen_condition_notEqual($1, $3);}
|   value SMALLER_THAN value                                              {if(DBG) cout << "st" << endl; $$ = gen_condition_smaller($1, $3);}
|   value BIGGER_THAN value                                               {if(DBG) cout << "bt" << endl; $$ = gen_condition_bigger($1, $3);}
|   value SMALLER_THAN_OR_EQUAL value                                     {if(DBG) cout << "set" << endl; $$ = gen_condition_smallerOrEqual($1, $3);}
|   value BIGGER_THAN_OR_EQUAL value                                      {if(DBG) cout << "bet" << endl; $$ = gen_condition_biggerOrEqual($1, $3);}
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

void endThisShit(int codePtr)
{
    ofstream myfile;
    myfile.open ("output.txt");

    finalizeJumps(codePtr);

    for(string instruction : codeFragments[codePtr])
    {
        myfile << instruction << endl;
    }

    myfile << "HALT" << endl;
        
    myfile.close();
    
}

int concatenate_codes(int c1, int c2)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[c1];
    code.insert(code.end(), codeFragments[c2].begin(), codeFragments[c2].end());
    
    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}


int gen_commnad_assign(int idt, int expr)
{
	cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[idt];                                           // zapisujemy adres zmiennej w rej a
    code.push_back("STORE 7");                                                          // zapisujemy go w rej 7
    code.insert(code.end(), codeFragments[expr].begin(), codeFragments[expr].end());    // zapisujemy wartosc wyrazenia w rej a
    code.push_back("STOREI 7");                                                         // zapisujemy ja pod zmienna

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_command_ifelse(int cond, int cmds_1, int cmds_2)
{
    cout << __FUNCTION__ << endl;
    
    int commandsLength = codeFragments[cmds_1].size();
    
    vector<string> code = codeFragments[cond];

    for(string& instruction : code)
    {
        if(instruction[0] == 'J' && instruction.find('x') != string::npos)
        {
            resolveJump(instruction, commandsLength+1);
        }
    }

    code.insert(code.end(), codeFragments[cmds_1].begin(), codeFragments[cmds_1].end());
    code.push_back("JUMP " + to_string(codeFragments[cmds_2].size()+1));
    code.insert(code.end(), codeFragments[cmds_2].begin(), codeFragments[cmds_2].end());

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_command_if(int cond, int cmds)
{
    cout << __FUNCTION__ << endl;
    
    int commandsLength = codeFragments[cmds].size();
    
    vector<string> code = codeFragments[cond];

    for(string& instruction : code)
    {
        if(instruction[0] == 'J' && instruction.find('x') != string::npos)
        {
            resolveJump(instruction, commandsLength);
        }
    }

    code.insert(code.end(), codeFragments[cmds].begin(), codeFragments[cmds].end());

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_command_while(int cond, int cmds)
{
    cout << __FUNCTION__ << endl;
    
    int commandsLength = codeFragments[cmds].size();
    
    vector<string> code = codeFragments[cond];

    for(string& instruction : code)
    {
        if(instruction[0] == 'J' && instruction.find('x') != string::npos)
        {
            resolveJump(instruction, commandsLength+1);
        }
    }

    code.insert(code.end(), codeFragments[cmds].begin(), codeFragments[cmds].end());
    code.push_back("JUMP -" + to_string(codeFragments[cmds].size() + codeFragments[cond].size()));

    codeFragments.push_back(code);
    return codeFragments.size() - 1;    
}


int gen_command_write(int v)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[v];

    code.push_back("STORE 8");
    code.push_back("LOADI 8");
    code.push_back("PUT");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}


int gen_condition_equal(int v1, int v2)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[v1];     
    
    code.push_back("STORE 6");
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());
    code.push_back("STORE 7");
    code.push_back("LOADI 6"); 
    code.push_back("INC");
    code.push_back("SUBI 7");
    code.push_back("JZERO x+4");
    code.push_back("DEC");
    code.push_back("JZERO 2");
    code.push_back("JUMP x+1");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_condition_notEqual(int v1, int v2)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[v1];     
    
    code.push_back("STORE 6");
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());
    code.push_back("STORE 7");
    code.push_back("LOADI 6"); 
    code.push_back("INC");
    code.push_back("SUBI 7");
    code.push_back("JZERO 3");
    code.push_back("DEC");
    code.push_back("JZERO x+1");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_condition_smaller(int v1, int v2)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[v1];     
    
    code.push_back("STORE 6");
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());
    code.push_back("STORE 7");
    code.push_back("LOADI 7"); 
    code.push_back("SUBI 6");
    code.push_back("JZERO x+1");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_condition_bigger(int v1, int v2)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[v1];     
    
    code.push_back("STORE 6");
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());
    code.push_back("STORE 7");
    code.push_back("LOADI 6"); 
    code.push_back("SUBI 7");
    code.push_back("JZERO x+1");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_condition_smallerOrEqual(int v1, int v2)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[v1];     
    
    code.push_back("STORE 6");
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());
    code.push_back("STORE 7");
    code.push_back("LOADI 6"); 
    code.push_back("SUBI 7");
    code.push_back("JZERO 2");
    code.push_back("JUMP x+1");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_condition_biggerOrEqual(int v1, int v2)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[v1];     
    
    code.push_back("STORE 6");
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());
    code.push_back("STORE 7");
    code.push_back("LOADI 7"); 
    code.push_back("SUBI 6");
    code.push_back("JZERO 2");
    code.push_back("JUMP x+1");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}



int gen_expr_value(int v)
{
    cout << __FUNCTION__ << endl;
    vector<string> code = codeFragments[v];     // ustawiamy adres zmiennej w rejestrze a
    code.push_back("STORE 1");                  // zapisujemy adres w rej 1
    code.push_back("LOADI 1");                  // ladujemy wartosc spod rej 1 
    
    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_expr_add(int v1, int v2)
{
	cout << __FUNCTION__ << endl;	
    vector<string> code = codeFragments[v1];                                         // ustawiamy adres zmiennej 1 w rej a
    code.push_back("STORE 1");                                                       // zapisujemy go w rej 1
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());     // ustawiamy adres zmiennej 2 w rej a
    code.push_back("STORE 2");                                                       // zapisujemy go w rej 2
    code.push_back("LOADI 1");                                                       // ladujemy wartosc spod zmiennej 1
    code.push_back("ADDI 2");                                                        // dodajemy do niej wartosc spod zmiennej 2
    
    codeFragments.push_back(code);

    return codeFragments.size() - 1;
}

int gen_expr_sub(int v1, int v2)
{
	cout << __FUNCTION__ << endl;	
    vector<string> code = codeFragments[v1];                                         // ustawiamy adres zmiennej 1 w rej a
    code.push_back("STORE 1");                                                       // zapisujemy go w rej 1
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());     // ustawiamy adres zmiennej 2 w rej a
    code.push_back("STORE 2");                                                       // zapisujemy go w rej 2
    code.push_back("LOADI 1");                                                       // ladujemy wartosc spod zmiennej 1
    code.push_back("SUBI 2");                                                        // odejmujemy od niej wartosc spod zmiennej 2
    
    codeFragments.push_back(code);

    return codeFragments.size() - 1;
}

int gen_expr_mult(int v1, int v2)
{
    cout << __FUNCTION__ << endl;

    vector<string> code = codeFragments[v1];
    code.push_back("STORE 2");
    code.push_back("LOADI 2");
    code.push_back("STORE 0");
    code.insert(code.end(), codeFragments[v2].begin(), codeFragments[v2].end());
    code.push_back("STORE 2");
    code.push_back("LOADI 2");
    code.push_back("STORE 1");

    code.push_back("ZERO");
    code.push_back("STORE 2");
    code.push_back("STORE 3");
    code.push_back("STORE 4");
    code.push_back("STORE 5");

    code.push_back("LOAD 1");
    code.push_back("JZERO 24");
    code.push_back("JODD 8");
    code.push_back("SHR");
    code.push_back("STORE 1");
    code.push_back("LOAD 3");
    code.push_back("INC");
    code.push_back("STORE 3");
    code.push_back("STORE 4");
    code.push_back("JUMP -9");
    code.push_back("LOAD 0");
    code.push_back("STORE 5");
    code.push_back("LOAD 4");
    code.push_back("JZERO 7");
    code.push_back("DEC");
    code.push_back("STORE 4");
    code.push_back("LOAD 5");
    code.push_back("SHL");
    code.push_back("STORE 5");
    code.push_back("JUMP -7");
    code.push_back("LOAD 5");
    code.push_back("ADD 2");
    code.push_back("STORE 2");
    code.push_back("LOAD 1");
    code.push_back("JUMP -21");
    code.push_back("LOAD 2");
    
    codeFragments.push_back(code);

    return codeFragments.size() - 1;
}

int gen_expr_div(int v1, int v2)
{
    vector<string> code = codeFragments[v2];
    code.push_back("STORE 5");
    code.push_back("LOADI 5");
    code.push_back("STORE 1");
    code.insert(code.end(), codeFragments[v1].begin(), codeFragments[v1].end());
    code.push_back("STORE 5");
    code.push_back("LOADI 5");
    code.push_back("STORE 0");

    // zapisz P pod mem[5], zacznij liczyć n
    code.push_back("STORE 5");
    code.push_back("ZERO");
    code.push_back("STORE 3");
    code.push_back("LOAD 5");
    code.push_back("JZERO 10");
        code.push_back("SHR");
        code.push_back("STORE 5");
        code.push_back("LOAD 1");
        code.push_back("SHL");
        code.push_back("STORE 1");
        code.push_back("LOAD 3");
        code.push_back("INC");
        code.push_back("STORE 3");
        code.push_back("JUMP -10");
    code.push_back("LOAD 3");
    code.push_back("STORE 4");
    // mem[3] = n, mem[4] = i = n-1

    // petla for - poczatek
    code.push_back("JZERO 27");
        // --i
        code.push_back("DEC");
        code.push_back("STORE 4");

        code.push_back("LOAD 0");
        code.push_back("SHL");
        code.push_back("STORE 5");
        code.push_back("LOAD 1");
        code.push_back("SUB 5");

        // if D < 2P
        code.push_back("JZERO 2");
        code.push_back("JUMP 10");
            code.push_back("LOAD 2");
            code.push_back("INC");
            code.push_back("SHL");
            code.push_back("STORE 2");
            code.push_back("LOAD 0");
            code.push_back("SHL");
            code.push_back("SUB 1");
            code.push_back("STORE 0");
            code.push_back("JUMP 7");
        //else
            code.push_back("LOAD 2");
            code.push_back("SHL");
            code.push_back("STORE 2");
            code.push_back("LOAD 0");
            code.push_back("SHL");
            code.push_back("STORE 0");
        
        code.push_back("LOAD 4");

    code.push_back("JUMP -26");

    code.push_back("LOAD 2");

    code.push_back("SHR");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}

int gen_expr_mod(int v1, int v2)
{
    vector<string> code = codeFragments[v2];
    code.push_back("STORE 5");
    code.push_back("LOADI 5");
    code.push_back("STORE 1");
    code.insert(code.end(), codeFragments[v1].begin(), codeFragments[v1].end());
    code.push_back("STORE 5");
    code.push_back("LOADI 5");
    code.push_back("STORE 0");

    // zapisz P pod mem[5], zacznij liczyć n
    code.push_back("STORE 5");
    code.push_back("ZERO");
    code.push_back("STORE 3");
    code.push_back("LOAD 5");
    code.push_back("JZERO 10");
        code.push_back("SHR");
        code.push_back("STORE 5");
        code.push_back("LOAD 1");
        code.push_back("SHL");
        code.push_back("STORE 1");
        code.push_back("LOAD 3");
        code.push_back("INC");
        code.push_back("STORE 3");
        code.push_back("JUMP -10");
    code.push_back("LOAD 3");
    code.push_back("STORE 4");
    // mem[3] = n, mem[4] = i = n-1

    // petla for - poczatek
    code.push_back("JZERO 27");
        // --i
        code.push_back("DEC");
        code.push_back("STORE 4");

        code.push_back("LOAD 0");
        code.push_back("SHL");
        code.push_back("STORE 5");
        code.push_back("LOAD 1");
        code.push_back("SUB 5");

        // if D < 2P
        code.push_back("JZERO 2");
        code.push_back("JUMP 10");
            code.push_back("LOAD 2");
            code.push_back("INC");
            code.push_back("SHL");
            code.push_back("STORE 2");
            code.push_back("LOAD 0");
            code.push_back("SHL");
            code.push_back("SUB 1");
            code.push_back("STORE 0");
            code.push_back("JUMP 7");
        //else
            code.push_back("LOAD 2");
            code.push_back("SHL");
            code.push_back("STORE 2");
            code.push_back("LOAD 0");
            code.push_back("SHL");
            code.push_back("STORE 0");
        
        code.push_back("LOAD 4");

    code.push_back("JUMP -26");

    code.push_back("LOAD 3");
    code.push_back("JZERO 7");
    code.push_back("DEC");
    code.push_back("STORE 3");
    code.push_back("LOAD 0");
    code.push_back("SHR");
    code.push_back("STORE 0");
    code.push_back("JUMP -7");
    code.push_back("LOAD 0");

    //code.push_back("SHR");

    codeFragments.push_back(code);
    return codeFragments.size() - 1;
}


int gen_ConstNumber(int num)
{
    cout << __FUNCTION__ << endl;
    vector<string> code;

    setRegister(code, memory_used++);       // zapisujemy adres gdzie stala bedzie przechowywana
    code.push_back("STORE 0");              // zapisujemy do rejestru 0
    setRegister(code, num);                 // ustawiamy wartosc stalej w rejestrze a
    code.push_back("STOREI 0");             // zapisujemy wartosc pod adres gdzie stala jest przechowywana
    code.push_back("LOAD 0");               // wykonujemy to co tzeba - ustawiamy rejestr a na adres stalej w pamieci
    
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
        // TEST ME
    	setRegister(code, variables[*arrayName]->memory_position);
    	code.push_back("ADD " + to_string(variables[*positionPid]->memory_position));
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

void resolveJump(std::string& instruction, int cmdsLength)
{
    // set jump value
    int xpos = instruction.find('x');
    int shift = stoi(instruction.substr(xpos+1, instruction.size()));

    cout << "resolve " << to_string(shift + cmdsLength) << endl;

    instruction.replace(xpos, instruction.size(), to_string(shift + cmdsLength));
}

void finalizeJumps(int finalCode)
{
    int k = 0;
    for(string& instruction : codeFragments[finalCode])
    {
        if(instruction[0] == 'J')
        {
            int pos = instruction.find(' ');
            int shift = stoi(instruction.substr(pos+1, instruction.size()));
            instruction.replace(pos+1, instruction.size(), to_string(shift + k));
        }
        k++;
    }
}

int main() 
{
  	cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n\n";
  	yy::cppcalc parser;
  	int v = parser.parse();
    cout << "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n";

  	return v;
}

namespace yy {
    void cppcalc::error(location const &loc, const std::string& s) {
        std::cerr << "error at " << loc << ": " << s << std::endl;
    }
}
