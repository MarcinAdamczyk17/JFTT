/* recognize tokens for the C++ calculator and print them out */
%option noyywrap
%{

	#include <stdlib.h>
	#include <cstring>
	#include <string.h>
	#include "cppcalc.tab.hh"

	#define YY_DECL int yylex(yy::cppcalc::semantic_type *yylval, yy::cppcalc::location_type *yylloc)
	#define YY_USER_ACTION yylloc->columns (yyleng);
	
	#define debug 0

	typedef yy::cppcalc::token token;

    bool for_flag = false;
%}
%x COMMENT
%%

"("                     BEGIN(COMMENT);
<COMMENT>")"            BEGIN(INITIAL);
<COMMENT>[^)]


"VAR"	    {if(debug) std::cout << yytext; return token::VAR;}
"BEGIN"	    {if(debug) std::cout << yytext; return token::START;}
"END"	    {if(debug) std::cout << yytext; return token::END;}
"IF"	    {if(debug) std::cout << yytext; return token::IF;}
"THEN"	    {if(debug) std::cout << yytext; return token::THEN;}
"ELSE"	    {if(debug) std::cout << yytext; return token::ELSE;}
"ENDIF"	    {if(debug) std::cout << yytext; return token::ENDIF;}
"WHILE"	    {if(debug) std::cout << yytext; return token::WHILE;}
"DO"	    {if(debug) std::cout << yytext; return token::DO;}
"ENDWHILE"  {if(debug) std::cout << yytext; return token::ENDWHILE;}
"FOR"	    {if(debug) std::cout << yytext; for_flag = true; return token::FOR;}
"FROM"	    {if(debug) std::cout << yytext; return token::FROM;}
"TO"	    {if(debug) std::cout << yytext; return token::TO;}
"DOWNTO"    {if(debug) std::cout << yytext; return token::DOWNTO;}
"ENDFOR"    {if(debug) std::cout << yytext; return token::ENDFOR;}
"READ"	    {if(debug) std::cout << yytext; return token::READ;}
"WRITE"	    {if(debug) std::cout << yytext; return token::WRITE;}
"SKIP"	    {if(debug) std::cout << yytext; return token::SKIP;}
";"	    	{if(debug) std::cout << yytext; return token::SC;}
":="	    {if(debug) std::cout << yytext; return token::ASSIGN;}
"="	    	{if(debug) std::cout << yytext; return token::EQUAL;}
"<>"	    {if(debug) std::cout << yytext; return token::DIFFERENT;}
"<"	    	{if(debug) std::cout << yytext; return token::SMALLER_THAN;}
">"	    	{if(debug) std::cout << yytext; return token::BIGGER_THAN;}
"<="	    {if(debug) std::cout << yytext; return token::SMALLER_THAN_OR_EQUAL;}
">="	    {if(debug) std::cout << yytext; return token::BIGGER_THAN_OR_EQUAL;}
""	    	{if(debug) std::cout << yytext; return token::VAR;}
"+"	    	{if(debug) std::cout << yytext; return token::ADD;}
"-"	    	{if(debug) std::cout << yytext; return token::SUB;}
"*"	    	{if(debug) std::cout << yytext; return token::MULT;}
"/"	    	{if(debug) std::cout << yytext; return token::DIV;}
"^"	    	{if(debug) std::cout << yytext; return token::POW;}
"["	    	{if(debug) std::cout << yytext; return token::LEFT_BRACKET;}
"]"	    	{if(debug) std::cout << yytext; return token::RIGHT_BRACKET;}
"%"	    	{if(debug) std::cout << yytext; return token::MOD;}

[_a-z]+	    {if(debug) std::cout << yytext; yylval->sval = new std::string(yytext, yyleng); return token::pidentifier;}
[0-9]+	    {if(debug) std::cout << yytext; yylval->llval = atoll(yytext); return token::num;}

\n	    	{if(debug) std::cout << yytext;}
[ \t]	    {if(debug) std::cout << yytext;}
.	    	{printf("unknown char %s", yytext); }

%%
