#pragma once

#include <string>
#include <vector>

void endThisShit(int);
void declareVariable(std::string*);
void declareArray(std::string*, int);

int concatenate_codes(int, int);

int gen_commnad_assign(int, int);
int gen_command_ifelse(int, int, int);
int gen_command_if(int, int);
int gen_command_while(int, int);
int gen_command_for_to(std::string*, int, int, int);
int gen_command_for_downto(std::string*, int, int, int);
int gen_command_write(int);
int gen_command_read(int);

int gen_condition_equal(int, int);
int gen_condition_notEqual(int, int);
int gen_condition_smaller(int, int);
int gen_condition_bigger(int, int);
int gen_condition_smallerOrEqual(int, int);
int gen_condition_biggerOrEqual(int, int);

int gen_expr_value(int);
int gen_expr_add(int, int);
int gen_expr_sub(int, int);
int gen_expr_mult(int, int);
int gen_expr_div(int, int);
int gen_expr_mod(int, int);

int gen_ConstNumber(unsigned long long);

int gen_Pidentifier(std::string*);
int gen_ArrayConst(std::string*, int);
int gen_ArrayPid(std::string*, std::string*);

void setRegister(std::vector<std::string>&, unsigned long long);


void printVector(std::vector<std::string>&);
void resolveJump(std::string&, int);
void finalizeJumps(int);
bool isAnyPossibleIteratorLeft();
void checkInitialization(int);