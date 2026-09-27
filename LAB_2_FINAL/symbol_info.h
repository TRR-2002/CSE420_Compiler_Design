#include<bits/stdc++.h>
using namespace std;

class symbol_info
{
private:
    string name; // stores the actual code text/result
    string type; 

    // Write necessary attributes to store what type of symbol it is (variable/array/function)
    string symbol_kind; // variable, array, function

    // Write necessary attributes to store the type/return type of the symbol (int/float/void/...)
    string data_type;   // "int", "float", "char", or "void"

    // Write necessary attributes to store the parameters of a function
    vector<string> func_parameter_types; // "int", "float", "char" 
    vector<string> func_parameter_names; // "x", "y", "z"
    int func_no_of_parameters; // number of parameters for a function

    // Write necessary attributes to store the array size if the symbol is an array
    int arr_size;

public:
    symbol_info(string name, string type)
    {
        this->name = name;
        this->type = type;
        this->func_no_of_parameters = 0;
        this->arr_size = 0;
    }
    string get_name()
    {
        return name;
    }
    string get_type()
    {
        return type;
    }

    string get_symbol_kind()
    {
        return symbol_kind;
    }

    string get_data_type()
    {
        return data_type;
    }

    vector<string> get_func_parameter_types()
    {
        return func_parameter_types;
    }

    vector<string> get_func_parameter_names()
    {
        return func_parameter_names;
    }

    int get_func_no_of_parameters()
    {
        return func_no_of_parameters;
    }

    int get_arr_size()
    {
        return arr_size;
    }







    void set_name(string name)
    {
        this->name = name;
    }
    void set_type(string type)
    {
        this->type = type;
    }
    void set_symbol_kind(string symbol_kind)
    {
        this->symbol_kind = symbol_kind;
    }

    void set_data_type(string data_type)
    {
        this->data_type = data_type;
    }

    void set_func_parameter_types(vector<string> func_parameter_types)
    {
        this->func_parameter_types = func_parameter_types;
    }

    void set_func_parameter_names(vector<string> func_parameter_names)
    {
        this->func_parameter_names = func_parameter_names;
    }

    void set_func_no_of_parameters(int func_no_of_parameters)
    {
        this->func_no_of_parameters = func_no_of_parameters;
    }

    void set_arr_size(int arr_size)
    {
        this->arr_size = arr_size;
    }
    

    ~symbol_info() //destructor
    {    // should work when delete symbol is called
        // Write necessary code to deallocate memory, if necessary
    }
};