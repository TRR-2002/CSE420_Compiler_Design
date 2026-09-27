%{

#include "symbol_table.h"

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

// create your symbol table here.
// You can store the pointer to your symbol table in a global variable
// or you can create an object



////////////////////////////
symbol_table *symb_table;
////////////////////////////




int lines = 1;
int error_count = 0; //error counter 

ofstream outlog;
ofstream outerr;//  Writes to the error output file

// you may declare other necessary variables here to store necessary info
// such as current variable type, variable list, function name, return type, function parameter types, parameters names etc.

//float x, arr[10];......


string current_variable_type; 
// stores the current declared type like int, float, char, void
// float..........


vector<string> variable_names; 
// stores variable names from a declaration list
// ["x", "arr"].........


vector<int> arr_sizes;
//[0, 10]


vector<string> func_parameter_types;
vector<string> func_parameter_names;



struct semantic_type_override
{
	symbol_info *symbol;
	string data_type;
};

vector<semantic_type_override> semantic_type_overrides;
int expression_value_required = 0;
//lab_3_imp



string current_function_name;
string current_function_return_type;





//lab_3_imp
vector<vector<string>> argument_type_stack;
// Each active function call gets its own argument-type list.


//helper to report symentic errors 

void print_error(string message)
{
	outlog << message << endl << endl;
	//outputs in the output file 

	outerr << message << endl << endl;
	//outputs in the error output file 

	error_count++;
}




// collects name & array sizes from the declaration_list 
// inserts them into the symbol table

void insert_variable_symbols()
{
	for (int i = 0; i < variable_names.size(); i++)
	{
		//lab_3_imp
		string symbol_data_type = current_variable_type;

		if (current_variable_type == "void")
		{
			print_error("At line no: " + to_string(lines) + " variable type can not be void ");
			symbol_data_type = "error";
		}
		//lab_3_imp

		symbol_info *new_symbol = new symbol_info(variable_names[i], "ID");

		new_symbol->set_data_type(symbol_data_type);

		if (arr_sizes[i] == 0)
		{
			new_symbol->set_symbol_kind("variable");
		}
		else
		{
			new_symbol->set_symbol_kind("array");
			new_symbol->set_arr_size(arr_sizes[i]);
		}

		if (!symb_table->insert(new_symbol))
		{
			print_error("At line no: " + to_string(lines) + " Multiple declaration of variable " + variable_names[i]);

			//lab_3_imp
			// Keeps compatibility types separate from the symbol table.
			symbol_info *existing_symbol = symb_table->lookup(new_symbol);
			bool override_updated = false;

			for (int j = 0; j < semantic_type_overrides.size(); j++)
			{
				if (semantic_type_overrides[j].symbol == existing_symbol)
				{
					semantic_type_overrides[j].data_type = current_variable_type;
					override_updated = true;
					break;
				}
			}

			if (existing_symbol != NULL && !override_updated)
			{
				semantic_type_override new_override;
				new_override.symbol = existing_symbol;
				new_override.data_type = current_variable_type;
				semantic_type_overrides.push_back(new_override);
			}
			//lab_3_imp

			delete new_symbol;
		}
	}

	variable_names.clear();
	arr_sizes.clear();
}




// used for function params
// inserted in the func body scope\

void insert_function_parameters()
{
	for (int i = 0; i < func_parameter_types.size(); i++)
	{
		if (func_parameter_names[i] == "")
		{
			continue;
		}

		symbol_info *parameter_symbol = new symbol_info(func_parameter_names[i], "ID");

		parameter_symbol->set_symbol_kind("variable");
		parameter_symbol->set_data_type(func_parameter_types[i]);

		symb_table->insert(parameter_symbol);
	}

	func_parameter_types.clear();
	func_parameter_names.clear();
}





symbol_info* find_symbol_from_table(string symbol_name)
{
	symbol_info *search_symbol = new symbol_info(symbol_name, "ID");

	symbol_info *found_symbol = symb_table->lookup(search_symbol);

	delete search_symbol;

	return found_symbol;
}



///........helpers for lab 3

string get_symbol_data_type(string symbol_name)
{
    symbol_info *found_symbol = find_symbol_from_table(symbol_name);

	if (found_symbol == NULL)
	{
		return "";
	}

	//lab_3_imp
	for (int i = 0; i < semantic_type_overrides.size(); i++)
	{
		if (semantic_type_overrides[i].symbol == found_symbol)
		{
			return semantic_type_overrides[i].data_type;
		}
	}
	//lab_3_imp

	return found_symbol->get_data_type();
}


string get_symbol_kind(string symbol_name)
{
	symbol_info *found_symbol = find_symbol_from_table(symbol_name);

	if (found_symbol == NULL)
	{
		return "";
	}

	return found_symbol->get_symbol_kind();
}




//helper for redeclaration checks


bool has_conflicting_redeclaration(symbol_info *symbol)
{
	if (symbol == NULL)
	{
		return false;
	}

	for (int i = 0; i < semantic_type_overrides.size(); i++)
	{
		if (semantic_type_overrides[i].symbol == symbol)
		{
			return true;
		}
	}

	return false;
}

// helper func to know the types of the arg 
string get_function_argument_type(symbol_info *argument)
{
	string argument_name = argument->get_name();
	symbol_info *direct_symbol = find_symbol_from_table(argument_name);

	if (direct_symbol != NULL && direct_symbol->get_symbol_kind() == "array")
	{
		return "array";
	}



	size_t left_bracket = argument_name.find('[');

	/*
		This line searches argument_name for the first 
		[ character and stores its position in left_bracket.
		as position of [ changes we have to go like this 
		num[0]
		number[0]
		numbers[0]
	*/


	// string::npos = no valid position


	if (left_bracket != string::npos && argument_name[argument_name.size() - 1] == ']')
	{
		string array_name = argument_name.substr(0, left_bracket);
		//................[

		symbol_info *array_symbol = find_symbol_from_table(array_name);
		// search for the array 

		if (array_symbol != NULL &&
			array_symbol->get_symbol_kind() == "array" &&
			has_conflicting_redeclaration(array_symbol))
		{
			return "invalid_argument";
		}
	}

	return argument->get_data_type();
}


string get_combined_data_type(string first_type, string second_type)
{
	if (first_type == "" || second_type == "")
	{
		return "";
	}

	if (first_type == "float" || second_type == "float")
	{
		return "float";
	}

	if (first_type == "int" && second_type == "int")
	{
		return "int";
	}

	if (first_type == second_type)
	{
		return first_type;
	}

	return "";
}

//lab_3_imp

void check_assignment_type(string left_variable_type, string right_expression_type)
{
    if (left_variable_type == "" || right_expression_type == "")
    {
        return;
    }

    if (left_variable_type == right_expression_type)
    {
        return;
    }

    if (left_variable_type == "float" && right_expression_type == "int")
    {
        return;
    }

    if (left_variable_type == "int" && right_expression_type == "float")
    {
        /*
        not in the output

        print_error("At line no: " + to_string(lines) + " Warning: possible loss of data in assignment of FLOAT to INT");
        */
        return;
    }

    print_error("At line no: " + to_string(lines) + " Type mismatch in assignment");
}

bool check_void_in_expression(string first_type, string second_type = "")
{
    if (first_type == "void" || second_type == "void")
    {
        /*
        not in the output

        print_error("At line no: " + to_string(lines) + " Void function used in expression");
        */
        return true;
    }

    return false;
}
//lab_3_imp

///........helpers for lab 3





bool check_function_argument_types(string function_name)
{
	//lab_3_imp
	vector<string> call_argument_types;

	if (!argument_type_stack.empty())
	{
		call_argument_types = argument_type_stack.back();
		argument_type_stack.pop_back();
	}
	//lab_3_imp

	symbol_info *function_symbol = find_symbol_from_table(function_name);

	if (function_symbol == NULL)
	{
		print_error("At line no: " + to_string(lines) + " Undeclared function: " + function_name);
		return true;
	}

	//lab_3_imp
	if (function_symbol->get_symbol_kind() != "function")
	{
		print_error("At line no: " + to_string(lines) + " " + function_name + " is not a function");
		return true;
	}
	//lab_3_imp

	vector<string> parameter_types = function_symbol->get_func_parameter_types();

	if (call_argument_types.size() != parameter_types.size())
	{
		print_error("At line no: " + to_string(lines) + " Inconsistencies in number of arguments in function call: " + function_name);
		return true;
	}

	bool argument_mismatch = false;

	for (int i = 0; i < call_argument_types.size() && i < parameter_types.size(); i++)
	{
		string actual_type = call_argument_types[i];
		string parameter_type = parameter_types[i];

		if (actual_type == "" || actual_type == "error")
		{
			continue;
		}

		bool types_match =
			actual_type == parameter_type ||
			(parameter_type == "float" && actual_type == "int");

		if (!types_match)
		{
			print_error("At line no: " + to_string(lines) + " argument " + to_string(i + 1) + " type mismatch in function call: " + function_name);
			argument_mismatch = true;
		}
	}

	return argument_mismatch;
}




void yyerror(char *s)
{
	outlog<<"At line "<<lines<<" "<<s<<endl<<endl;

    // you may need to reinitialize variables if you find an error
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

//....................................1

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;
		
		symb_table->print_all_scopes(outlog);
	}
	;

//....................................2

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->get_name()+"\n"+$2->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name()+"\n"+$2->get_name(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name(),"program");
	}
	;

//....................................3

unit : variable_decl
	 {
		outlog<<"At line no: "<<lines<<" unit : variable_decl "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
		
		$$ = new symbol_info($1->get_name(),"unit");
	 }
     ;

//....................................4

func_definition : type_specifier ID LPAREN
		{
			//lab_3_imp
			current_function_name = $2->get_name();
			current_function_return_type = $1->get_name();
			//lab_3_imp
		}
		param_list RPAREN insert_function compound_statement
		{	
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN param_list RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<"("+$5->get_name()+")\n"<<$8->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+"("+$5->get_name()+")\n"+$8->get_name(),"func_def");
		}
		| type_specifier ID LPAREN
		{
			//lab_3_imp
			current_function_name = $2->get_name();
			current_function_return_type = $1->get_name();
			//lab_3_imp
		}
		RPAREN insert_function compound_statement
		{
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<"()\n"<<$7->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+"()\n"+$7->get_name(),"func_def");	
		}
 		;

//....................................5

insert_function :
		{
			symbol_info *function_symbol = new symbol_info(current_function_name, "ID");

			function_symbol->set_symbol_kind("function");
			function_symbol->set_data_type(current_function_return_type);
			function_symbol->set_func_parameter_types(func_parameter_types);
			function_symbol->set_func_parameter_names(func_parameter_names);
			function_symbol->set_func_no_of_parameters(func_parameter_types.size());

			if (!symb_table->insert(function_symbol))
			{
				print_error("At line no: " + to_string(lines) + " Multiple declaration of function " + current_function_name);
				delete function_symbol;
			}
		}
		;

//....................................6

param_list : param_list COMMA type_specifier ID
		{
			outlog<<"At line no: "<<lines<<" param_list : param_list COMMA type_specifier ID "<<endl<<endl;
			outlog<<$1->get_name()<<","<<current_variable_type<<" "<<$4->get_name()<<endl<<endl;
					
			$$ = new symbol_info($1->get_name()+","+current_variable_type+" "+$4->get_name(),"param_list");
			
			bool duplicate_parameter = false;

			for (int i = 0; i < func_parameter_names.size(); i++)
			{
				if (func_parameter_names[i] == $4->get_name())
				{
					duplicate_parameter = true;
					break;
				}
			}

			if (duplicate_parameter)
			{
				print_error("At line no: " + to_string(lines) + " Multiple declaration of variable " + $4->get_name() + " in parameter of " + current_function_name);
			}

			//lab_3_imp
			// Keep the duplicate in the function metadata for the log.
			func_parameter_types.push_back(current_variable_type);
			func_parameter_names.push_back($4->get_name());
			//lab_3_imp
		}
		| param_list COMMA type_specifier
		{
			outlog<<"At line no: "<<lines<<" param_list : param_list COMMA type_specifier "<<endl<<endl;
			outlog<<$1->get_name()<<","<<current_variable_type<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+","+current_variable_type,"param_list");
			
			func_parameter_types.push_back(current_variable_type);
			func_parameter_names.push_back("");
		}
 		| type_specifier ID
 		{
			outlog<<"At line no: "<<lines<<" param_list : type_specifier ID "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+" "+$2->get_name(),"param_list");
			
			func_parameter_types.push_back($1->get_name());
			func_parameter_names.push_back($2->get_name());
		}
		| type_specifier
		{
			outlog<<"At line no: "<<lines<<" param_list : type_specifier "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"param_list");
			
			func_parameter_types.push_back($1->get_name());
			func_parameter_names.push_back("");
		}
 		;

//....................................7

compound_statement : LCURL enter_scope statements RCURL
			{ 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
				outlog<<"{\n"+$3->get_name()+"\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n"+$3->get_name()+"\n}","comp_stmnt");

				symb_table->print_all_scopes(outlog);

				int removed_scope_id = symb_table->get_current_scope_id();

				symb_table->exit_scope();

				outlog << "Scopetable with ID " << removed_scope_id << " removed" << endl << endl;
				
 		    }
 		    | LCURL enter_scope RCURL
 		    { 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
				outlog<<"{\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n}","comp_stmnt");

				symb_table->print_all_scopes(outlog);

				int removed_scope_id = symb_table->get_current_scope_id();

				symb_table->exit_scope();

				outlog << "Scopetable with ID " << removed_scope_id << " removed" << endl << endl;
				
 		    }
 		    ;

//....................................8

enter_scope :
			{
				symb_table->enter_scope();
				outlog << "New ScopeTable with ID " << symb_table->get_current_scope_id() << " created" << endl << endl;
				insert_function_parameters();
			}
			;

//....................................9

variable_decl : type_specifier declaration_list SEMICOLON
		 {
			outlog<<"At line no: "<<lines<<" variable_decl : type_specifier declaration_list SEMICOLON "<<endl<<endl;
			outlog<<$1->get_name()<<" "<<$2->get_name()<<";"<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+" "+$2->get_name()+";","var_dec");
			
			insert_variable_symbols();
		 }
 		 ;

//....................................10

type_specifier : INT
		{
			outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
			outlog<<"int"<<endl<<endl;

			current_variable_type = "int";
			
			$$ = new symbol_info("int","type");
	    }
 		| FLOAT
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
			outlog<<"float"<<endl<<endl;

			current_variable_type = "float";
			
			$$ = new symbol_info("float","type");
	    }
 		| VOID
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
			outlog<<"void"<<endl<<endl;

			current_variable_type = "void";
			
			$$ = new symbol_info("void","type");
	    }
		| CHAR
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : CHAR "<<endl<<endl;
			outlog<<"char"<<endl<<endl;

			current_variable_type = "char";
			
			$$ = new symbol_info("char","type");
	    }
 		;

//....................................11

declaration_list : declaration_list COMMA ID
		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
 		  	outlog<<$1->get_name()+","<<$3->get_name()<<endl<<endl;

			variable_names.push_back($3->get_name());
			arr_sizes.push_back(0);

			$$ = new symbol_info($1->get_name()+","+$3->get_name(),"decl_list");
			
 		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD //array after some declaration
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 		  	outlog<<$1->get_name()+","<<$3->get_name()<<"["<<$5->get_name()<<"]"<<endl<<endl;

			variable_names.push_back($3->get_name());
			arr_sizes.push_back(stoi($5->get_name()));

			$$ = new symbol_info($1->get_name()+","+$3->get_name()+"["+$5->get_name()+"]","decl_list");
			
 		  }
 		  |ID
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;

			variable_names.push_back($1->get_name());
			arr_sizes.push_back(0);

			$$ = new symbol_info($1->get_name(),"decl_list");
			
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD //array
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
			outlog<<$1->get_name()<<"["<<$3->get_name()<<"]"<<endl<<endl;

			variable_names.push_back($1->get_name());
			arr_sizes.push_back(stoi($3->get_name()));

			$$ = new symbol_info($1->get_name()+"["+$3->get_name()+"]","decl_list");
            
 		  }
 		  ;
 		  

//....................................12

statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"stmnts");
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			outlog<<$1->get_name()<<"\n"<<$2->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name()+"\n"+$2->get_name(),"stmnts");
	   }
	   ;
	   
//....................................13

statement : variable_decl
	  {
	    	outlog<<"At line no: "<<lines<<" statement : variable_decl "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1->get_name()<<endl<<endl;

            $$ = new symbol_info($1->get_name(),"stmnt");
	  		
	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->get_name()<<$4->get_name()<<$5->get_name()<<")\n"<<$7->get_name()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3->get_name()+$4->get_name()+$5->get_name()+")\n"+$7->get_name(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3->get_name()<<")\n"<<$5->get_name()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->get_name()+")\n"+$5->get_name(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3->get_name()<<")\n"<<$5->get_name()<<"\nelse\n"<<$7->get_name()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->get_name()+")\n"+$5->get_name()+"\nelse\n"+$7->get_name(),"stmnt");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3->get_name()<<")\n"<<$5->get_name()<<endl<<endl;
			
			$$ = new symbol_info("while("+$3->get_name()+")\n"+$5->get_name(),"stmnt");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3->get_name()<<");"<<endl<<endl; 

			if (find_symbol_from_table($3->get_name()) == nullptr)
			{
				print_error("At line no: " + to_string(lines) + " Undeclared variable " + $3->get_name());
			}
			
			$$ = new symbol_info("printf("+$3->get_name()+");","stmnt");
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2->get_name()<<";"<<endl<<endl;
			
			$$ = new symbol_info("return "+$2->get_name()+";","stmnt");
	  }
	  ;
	  
//....................................14

expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->get_name()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1->get_name()+";","expr_stmt");
	        }
			;
	  
//....................................15

variable : ID 	
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;

		symbol_info *found_symbol = find_symbol_from_table($1->get_name());
		if (found_symbol == NULL)
		{
			print_error("At line no: " + to_string(lines) + " Undeclared variable " + $1->get_name());
		}
		else if (found_symbol->get_symbol_kind() == "array")
		{
			print_error("At line no: " + to_string(lines) + " variable is of array type : " + $1->get_name());
		}
			
		$$ = new symbol_info($1->get_name(),"varbl");
		$$->set_data_type(get_symbol_data_type($1->get_name()));
		
	 }	
	 | ID LTHIRD expression RTHIRD 
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1->get_name()<<"["<<$3->get_name()<<"]"<<endl<<endl;

		symbol_info *found_symbol = find_symbol_from_table($1->get_name());
		if (found_symbol == NULL)
		{
			print_error("At line no: " + to_string(lines) + " Undeclared variable " + $1->get_name());
		}
		else if (found_symbol->get_symbol_kind() != "array")
		{
			print_error("At line no: " + to_string(lines) + " variable is not of array type : " + $1->get_name());
		}

		//lab_3_imp
		bool invalid_array_index = ($3->get_data_type() != "int");
		bool has_conflicting_redeclaration = false;

		has_conflicting_redeclaration = ::has_conflicting_redeclaration(found_symbol);

		if (found_symbol != NULL &&
			found_symbol->get_symbol_kind() == "array" &&
			has_conflicting_redeclaration)
		{
			invalid_array_index = true;
		}

		if (invalid_array_index)
		{
			print_error("At line no: " + to_string(lines) + " array index is not of integer type : " + $1->get_name());
		}
		//lab_3_imp
		
		$$ = new symbol_info($1->get_name()+"["+$3->get_name()+"]","varbl");
		$$->set_data_type(get_symbol_data_type($1->get_name()));
	 }
	 ;
	 
//....................................16

expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"expr");
			$$->set_data_type($1->get_data_type());
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->get_name()<<"="<<$3->get_name()<<endl<<endl;
			//lab_3_imp
			if (!check_void_in_expression($3->get_data_type()))
			{
				check_assignment_type($1->get_data_type(), $3->get_data_type());
			}
			//lab_3_imp
			$$ = new symbol_info($1->get_name()+"="+$3->get_name(),"expr");
			$$->set_data_type($1->get_data_type());
	   }
	   ;
			
//....................................17

logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"lgc_expr");
			$$->set_data_type($1->get_data_type());
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			//lab_3_imp
			bool void_used = check_void_in_expression($1->get_data_type(), $3->get_data_type());

			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"lgc_expr");

			if (void_used || $1->get_data_type() == "" || $3->get_data_type() == "")
			{
				$$->set_data_type("");
			}
			else
			{
				$$->set_data_type("int");
			}
	     }	
		 //lab_3_imp
		 ;
			
//....................................18

rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"rel_expr");
			$$->set_data_type($1->get_data_type());
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;
			//lab_3_imp
			bool void_used = check_void_in_expression($1->get_data_type(), $3->get_data_type());

			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"rel_expr");

			if (void_used || $1->get_data_type() == "" || $3->get_data_type() == "")
			{
				$$->set_data_type("");
			}
			else
			{
				$$->set_data_type("int");
			}
			//lab_3_imp
	    }
		;
				
//....................................19

simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"simp_expr");
			$$->set_data_type($1->get_data_type());
			
	      }
		  | simple_expression ADDOP term 
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$3->get_name()<<endl<<endl;

			bool void_used = check_void_in_expression($1->get_data_type(), $3->get_data_type());
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$3->get_name(),"simp_expr");

			if (void_used)
			{
				$$->set_data_type("");
			}
			else
			{
				$$->set_data_type(get_combined_data_type($1->get_data_type(), $3->get_data_type()));
			}
	      }
		  ;
					
//....................................20

term :	unary_expression //term can be void because of un_expr->factor
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"term");
			$$->set_data_type($1->get_data_type());
			$$->set_value($1->get_value());
			
	 }
	 |  term MULOP
	 {
		//lab_3_imp
		expression_value_required++;
		//lab_3_imp
	 }
	 unary_expression
	 {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<$4->get_name()<<endl<<endl;

			expression_value_required--;

			bool void_used = check_void_in_expression($1->get_data_type(), $4->get_data_type());

			if ($2->get_name() == "%" && ($1->get_data_type() != "int" || $4->get_data_type() != "int"))
			{
				/*
				not in the output

				print_error("At line no: " + to_string(lines) + " Both operands of modulus operator should be integers");
				*/
			}

			if (($2->get_name() == "/" || $2->get_name() == "%") && $4->get_value() == "0")
			{
				/*
				not in the output

				print_error("At line no: " + to_string(lines) + " Warning: division by zero");
				*/
			}
			
			$$ = new symbol_info($1->get_name()+$2->get_name()+$4->get_name(),"term");

			if (void_used)
			{
				$$->set_data_type("");
			}
			else
			{
				$$->set_data_type(get_combined_data_type($1->get_data_type(), $4->get_data_type()));
			}
			
	 }
     ;

//....................................21

unary_expression : ADDOP unary_expression  // un_expr can be void because of factor
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1->get_name()<<$2->get_name()<<endl<<endl;
			////lab_3_imp
			bool void_used = check_void_in_expression($2->get_data_type());

			$$ = new symbol_info($1->get_name()+$2->get_name(),"un_expr");

			if (void_used || $2->get_data_type() == "")
			{
				$$->set_data_type("");
			}
			else
			{
				$$->set_data_type($2->get_data_type());
			}
			//lab_3_imp
	     }
		 | NOT unary_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2->get_name()<<endl<<endl;
			//lab_3_imp
			bool void_used = check_void_in_expression($2->get_data_type());

			$$ = new symbol_info("!"+$2->get_name(),"un_expr");

			if (void_used || $2->get_data_type() == "")
			{
				$$->set_data_type("");
			}
			else
			{
				$$->set_data_type("int");
			}
			//lab_3_imp
	     }
		 | factor_info
		 	{
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor_info "<<endl<<endl;
			outlog<<$1->get_name()<<endl<<endl;
			
			$$ = new symbol_info($1->get_name(),"un_expr");
			$$->set_data_type($1->get_data_type());
			$$->set_value($1->get_value());
	     }
		 ;
//....................................22

factor_info : factor	{
	    outlog<<"At line no: "<<lines<<" factor_info : factor "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr_info");
		$$->set_data_type($1->get_data_type());
		$$->set_value($1->get_value());
	}	
//....................................23

factor	: variable // a = b
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
		$$->set_data_type($1->get_data_type());
	}
	| ID LPAREN
	{
		//lab_3_imp
		vector<string> new_argument_list;
		argument_type_stack.push_back(new_argument_list);// pushes arg types 
		//lab_3_imp
	}
	argument_list RPAREN
	{
	    outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
		outlog<<$1->get_name()<<"("<<$4->get_name()<<")"<<endl<<endl;

		bool argument_error = check_function_argument_types($1->get_name());

		$$ = new symbol_info($1->get_name()+"("+$4->get_name()+")","fctr");

		//lab_3_imp
		if (get_symbol_kind($1->get_name()) == "function")
		{
			$$->set_data_type(get_symbol_data_type($1->get_name()));

			if ($$->get_data_type() == "void" &&
				expression_value_required > 0 &&
				!argument_error)
			{
				print_error("At line no: " + to_string(lines) + " argument 1 type mismatch in function call: " + $1->get_name());
			}
		}
		else
		{
			$$->set_data_type("");
		}
		//lab_3_imp
	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2->get_name()<<")"<<endl<<endl;
		
		$$ = new symbol_info("("+$2->get_name()+")","fctr");
		$$->set_data_type($2->get_data_type());
		$$->set_value($2->get_value());
	}
	| CONST_INT //a = 5
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
		$$->set_data_type("int");
		$$->set_value($1->get_name());



	}
	| CONST_FLOAT // a = 0.5
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1->get_name()<<endl<<endl;
			
		$$ = new symbol_info($1->get_name(),"fctr");
		$$->set_data_type("float");
		$$->set_value($1->get_name());





	}
	| variable INCOP 
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1->get_name()<<"++"<<endl<<endl;
			
		$$ = new symbol_info($1->get_name()+"++","fctr");

		//lab_3_imp
		$$->set_data_type($1->get_data_type());
		//lab_3_imp
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1->get_name()<<"--"<<endl<<endl;
			
		$$ = new symbol_info($1->get_name()+"--","fctr");

		//lab_3_imp
		$$->set_data_type($1->get_data_type());
		//lab_3_imp
	}
	;
	
//....................................24

argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1->get_name()<<endl<<endl;
						
					$$ = new symbol_info($1->get_name(),"arg_list");
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;

					$$ = new symbol_info("","arg_list");
			  }
			  ;
	
//....................................25

arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1->get_name()<<","<<$3->get_name()<<endl<<endl;
				//lab_3_imp
				argument_type_stack.back().push_back(get_function_argument_type($3));
				//lab_3_imp
						
				$$ = new symbol_info($1->get_name()+","+$3->get_name(),"arg");
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1->get_name()<<endl<<endl;



				//lab_3_imp

				// using the helper to get all arg types


				argument_type_stack.back().push_back(get_function_argument_type($1));

				//lab_3_imp
				$$ = new symbol_info($1->get_name(),"arg");
		  }
	      ;
 

%%

int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
		cout<<"Please input file name"<<endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("23101350_log.txt", ios::trunc);

	//open error file 
	outerr.open("23101350_error.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}




    ///////////////////////////////
	// Enter the global or the first scope here
	symb_table = new symbol_table(10);
	outlog << "New ScopeTable with ID " << symb_table->get_current_scope_id() << " created" << endl << endl;
    /////////////////////////////////




	yyparse();
	
	outlog<<endl<<"Total lines: "<<lines<<endl;
	
	//add the error numbers in the output files 
	outlog << "Total errors: " << error_count << '\n';
	outerr << "Total errors: " << error_count << endl;
	
	outlog.close();

	outerr.close();//clos the new error output file
	
	fclose(yyin);
	
	return 0;
}




/*

start : program

func_definition

insert_function
This is newly added helper grammar.

param_list

compound_statement

enter_scope
This is newly added helper grammar.

variable_decl

type_specifier

declaration_list

factor : ID LPAREN argument_list RPAREN

argument_list

arguments

*/
