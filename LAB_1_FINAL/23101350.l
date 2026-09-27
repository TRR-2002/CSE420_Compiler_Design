%option noyywrap

%{
#include<bits/stdc++.h>

#include"symbol_info.h"

#define YYSTYPE symbol_info*

#include "y.tab.h"

extern YYSTYPE yylval;

using namespace std;

void yyerror(char *);


string loglist;

extern int line_num;

extern ofstream outlog;

%}

/* Regular Definitions */

delim	        [ \t\v\r]
ws              {delim}+
newline         \n

letter_	        [A-Za-z_]
digit	        [0-9]



/*
a. Integer Literals: 
One or more consecutive digits form an integer literal. 
The type of token will be CONST_INT. Note that + or - will
not be the part of an integer.
*/


int_num         {digit}+


/*
 b. Floating Point Literals: 
Numbers like 3.14159, 3.14159E-10, .314159 and  
314159E10 will be considered as floating point constants. 
In this case, the token type   
will be  CONST_FLOAT. 

*/


/*
3.14159
*/

alt1            {digit}+\.{digit}*

/*
.314159
*/

alt2            \.{digit}+

float_without_E ({alt1}|{alt2})

exp             [Ee]
opt_sign        [+-]
exponent_part1  {exp}{opt_sign}{digit}+
exponent_part2  {exp}{digit}+

exponent        ({exponent_part1}|{exponent_part2})

float_with_E    {float_without_E}{exponent}
integer_with_E  {digit}+{exponent}


float_num       ({float_without_E}|{float_with_E}|{integer_with_E})


/*
Identifiers 
Identifiers are names given to entities, such as variables, 
functions, structures etc. An identifier can only have alphanumeric 
characters (a-z, A-Z, 0-9) and underscore (_). The first character of 
an identifier can only contain the alphabet (a-z, A-Z) or underscore (_).
*/

id	            {letter_}({letter_}|{digit})*



%% //..................definition ends...........Rules and action starts

{ws}		{ /* ignore whitespace */ }
{newline}	{ line_num++; }


"if"        {
                loglist="Line no "+to_string(line_num)+": Token <IF> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return IF;
            }

"else"      {
                loglist="Line no "+to_string(line_num)+": Token <ELSE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return ELSE;
            }

"void"      {
                loglist="Line no "+to_string(line_num)+": Token <VOID> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return VOID;
            }

"for"       {
                loglist="Line no "+to_string(line_num)+": Token <FOR> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return FOR;
            }


"while"     {
                loglist="Line no "+to_string(line_num)+": Token <WHILE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return WHILE;
            }


            
"switch"    {
                loglist="Line no "+to_string(line_num)+": Token <SWITCH> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return SWITCH;
            }

"do"        {
                loglist="Line no "+to_string(line_num)+": Token <DO> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return DO;
            }

"break"     {
                loglist="Line no "+to_string(line_num)+": Token <BREAK> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return BREAK;
            }

"default"   {
                loglist="Line no "+to_string(line_num)+": Token <DEFAULT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return DEFAULT;
            }

"int"       {
                loglist="Line no "+to_string(line_num)+": Token <INT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return INT;
            }

"char"      {
                loglist="Line no "+to_string(line_num)+": Token <CHAR> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return CHAR;
            }

"goto"      {
                loglist="Line no "+to_string(line_num)+": Token <GOTO> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return GOTO;
            }

"float"     {
                loglist="Line no "+to_string(line_num)+": Token <FLOAT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return FLOAT;
            }

"double"    {
                loglist="Line no "+to_string(line_num)+": Token <DOUBLE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return DOUBLE;
            }

"return"    {
                loglist="Line no "+to_string(line_num)+": Token <RETURN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RETURN;
            }

"continue"  {
                loglist="Line no "+to_string(line_num)+": Token <CONTINUE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return CONTINUE;
            }

"case"      {
                loglist="Line no "+to_string(line_num)+": Token <CASE> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return CASE;
            }

"printf"    {
                loglist="Line no "+to_string(line_num)+": Token <PRINTLN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return PRINTLN;
            }


{float_num} {
                symbol_info *s = new symbol_info((string)yytext, "CONST_FLOAT");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(line_num)+": Token <CONST_FLOAT> Lexeme "+yytext+" found\n\n";
                outlog<<loglist;
                return CONST_FLOAT;
            }

{int_num}   {
                symbol_info *s = new symbol_info((string)yytext, "CONST_INT");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(line_num)+": Token <CONST_INT> Lexeme "+yytext+" found\n\n";
                outlog<<loglist;
                return CONST_INT;
            }

{id}       {
                symbol_info *s = new symbol_info((string)yytext,"ID");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(line_num)+": Token <ID> Lexeme "+yytext+" found"+"\n"+"\n";
			    outlog<<loglist;
                return ID;
            }


"++"        {

                loglist="Line no "+to_string(line_num)+": Token <INCOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return INCOP;
            }

"--"        {

                loglist="Line no "+to_string(line_num)+": Token <DECOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return DECOP;
            }

"&&"|"||"   {
                symbol_info *s = new symbol_info((string)yytext,"LOGICOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(line_num)+": Token <LOGICOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LOGICOP;
            }

"<"|">"|"=="|"<="|">="|"!=" {
                symbol_info *s = new symbol_info((string)yytext,"RELOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(line_num)+": Token <RELOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RELOP;
            }

"+"|"-"     {
                symbol_info *s = new symbol_info((string)yytext,"ADDOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(line_num)+": Token <ADDOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return ADDOP;
            }

"*"|"/"|"%" {
                symbol_info *s = new symbol_info((string)yytext,"MULOP");
                yylval = (YYSTYPE)s;
                loglist="Line no "+to_string(line_num)+": Token <MULOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return MULOP;
            }

"="         {
                loglist="Line no "+to_string(line_num)+": Token <ASSIGNOP> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return ASSIGNOP;
            }

"!"         {
                loglist="Line no "+to_string(line_num)+": Token <NOT> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return NOT;
            }

"("         {
                loglist="Line no "+to_string(line_num)+": Token <LPAREN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LPAREN;
            }

")"         {
                loglist="Line no "+to_string(line_num)+": Token <RPAREN> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RPAREN;
            }

"{"         {
                loglist="Line no "+to_string(line_num)+": Token <LCURL> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LCURL;
            }

"}"         {
                loglist="Line no "+to_string(line_num)+": Token <RCURL> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RCURL;
            }

"["         {
                loglist="Line no "+to_string(line_num)+": Token <LTHIRD> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return LTHIRD;
            }

"]"         {
                loglist="Line no "+to_string(line_num)+": Token <RTHIRD> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return RTHIRD;
            }

","         {
                loglist="Line no "+to_string(line_num)+": Token <COMMA> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return COMMA;
            }

":"         {
                loglist="Line no "+to_string(line_num)+": Token <COLON> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return COLON;
            }

";"         {
                loglist="Line no "+to_string(line_num)+": Token <SEMICOLON> Lexeme "+yytext+" found"+"\n"+"\n";
                outlog<<loglist;
                return SEMICOLON;
            }

%%
