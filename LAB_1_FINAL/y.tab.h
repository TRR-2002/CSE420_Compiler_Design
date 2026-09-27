/* A Bison parser, made by GNU Bison 2.7.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2012 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IF = 258,
     ELSE = 259,
     VOID = 260,
     FOR = 261,
     WHILE = 262,
     SWITCH = 263,
     DO = 264,
     BREAK = 265,
     DEFAULT = 266,
     INT = 267,
     CHAR = 268,
     GOTO = 269,
     FLOAT = 270,
     DOUBLE = 271,
     RETURN = 272,
     CONTINUE = 273,
     CASE = 274,
     PRINTLN = 275,
     CONST_FLOAT = 276,
     CONST_INT = 277,
     ID = 278,
     INCOP = 279,
     DECOP = 280,
     LOGICOP = 281,
     RELOP = 282,
     ADDOP = 283,
     MULOP = 284,
     ASSIGNOP = 285,
     NOT = 286,
     LPAREN = 287,
     RPAREN = 288,
     LCURL = 289,
     RCURL = 290,
     LTHIRD = 291,
     RTHIRD = 292,
     COMMA = 293,
     COLON = 294,
     SEMICOLON = 295,
     CONFLICT_REMOVER = 296
   };
#endif
/* Tokens.  */
#define IF 258
#define ELSE 259
#define VOID 260
#define FOR 261
#define WHILE 262
#define SWITCH 263
#define DO 264
#define BREAK 265
#define DEFAULT 266
#define INT 267
#define CHAR 268
#define GOTO 269
#define FLOAT 270
#define DOUBLE 271
#define RETURN 272
#define CONTINUE 273
#define CASE 274
#define PRINTLN 275
#define CONST_FLOAT 276
#define CONST_INT 277
#define ID 278
#define INCOP 279
#define DECOP 280
#define LOGICOP 281
#define RELOP 282
#define ADDOP 283
#define MULOP 284
#define ASSIGNOP 285
#define NOT 286
#define LPAREN 287
#define RPAREN 288
#define LCURL 289
#define RCURL 290
#define LTHIRD 291
#define RTHIRD 292
#define COMMA 293
#define COLON 294
#define SEMICOLON 295
#define CONFLICT_REMOVER 296



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
