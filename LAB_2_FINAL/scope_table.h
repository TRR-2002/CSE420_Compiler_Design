#include "symbol_info.h"

class scope_table
{
private:
    int bucket_count;// size of scope table//index
    int unique_id;// unique id of the scope table

    //pointer to the parent scope table if any
    //If this is the global scope table, then this will be NULL
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table; // list cuz it will handel collisions in the hash table using chaining


    // generates in which index of the table the symbol should be inserted
   

    int hash_function(string name)
    {
        // write your hash function here
        // generate ascii values for each latter o name
        //sum the ascii values and take mod with bucket_count to get the index

        int ascii_sum = 0;

        for (char character : name)
        
        {
            ascii_sum += character;
        }

        return ascii_sum % bucket_count;

    }


public:
    scope_table()
    {  
        bucket_count = 0;
        unique_id = 0;
        parent_scope = NULL;
    }



    //constructoe method
    //given int bucket_count, int unique_id, scope_table *parent_scope by the symbol table
    //save the values provided in the private variables
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope)
    {
        this->bucket_count = bucket_count;
        this->unique_id = unique_id;
        this->parent_scope = parent_scope;
        create_table(bucket_count);
    }
    void create_table(int bucket_count)
    {
        table.resize(bucket_count);
        // this tells our vector var to have bucket_count number of lists
        // each list will be used to store the symbols in that
        // index of the hash table
    }


    scope_table *get_parent_scope()
    {
        return parent_scope;
    }

    int get_unique_id()
    {
        return unique_id;
    }

    

    symbol_info *find_symbol_in_list(list<symbol_info *> &symbol_list_in_a_scope_idx, string symbol_name)
    {
        for (auto it = symbol_list_in_a_scope_idx.begin(); it != symbol_list_in_a_scope_idx.end(); it++)
        {
            symbol_info *current_symbol = *it;

            if (current_symbol->get_name() == symbol_name)
            {
                return current_symbol;
            }
        }

        return NULL;
    }

    symbol_info *lookup_in_scope(symbol_info* symbol)
    {
        string symbol_name = symbol->get_name();

        int index = hash_function(symbol_name);

        list<symbol_info *> &symbol_list_in_a_scope_idx = table[index];

        return find_symbol_in_list(symbol_list_in_a_scope_idx, symbol_name);
    }





    bool insert_in_scope(symbol_info* symbol)
    {
        string symbol_name = symbol->get_name();

        int index = hash_function(symbol_name);

        list<symbol_info *> &symbol_list_in_a_scope_idx = table[index];

        symbol_info *found_symbol = find_symbol_in_list(symbol_list_in_a_scope_idx, symbol_name);

        if (found_symbol != NULL)
        {
            return false;
        }

        symbol_list_in_a_scope_idx.push_back(symbol);

        return true;
    }
    //insert only if not in the table already

    bool helper_delete_symbol_from_list(list<symbol_info *> &symbol_list_in_a_scope_idx, string symbol_name)
    {
        for (auto it = symbol_list_in_a_scope_idx.begin(); it != symbol_list_in_a_scope_idx.end(); it++)
        {
            symbol_info *current_symbol = *it;

            if (current_symbol->get_name() == symbol_name)
            {
                delete current_symbol;
                symbol_list_in_a_scope_idx.erase(it);
                return true;
            }
        }

        return false;
    }

    bool delete_from_scope(symbol_info* symbol)
    {
        string symbol_name = symbol->get_name();

        int index = hash_function(symbol_name);

        list<symbol_info *> &symbol_list_in_a_scope_idx = table[index];

        return helper_delete_symbol_from_list(symbol_list_in_a_scope_idx, symbol_name);
    }





    void helper_print_symbol_list(list<symbol_info *> &symbol_list_in_a_scope_idx, ofstream& outlog)
    {
        for (auto it = symbol_list_in_a_scope_idx.begin(); it != symbol_list_in_a_scope_idx.end(); it++)
        {
            symbol_info *current_symbol = *it;

            outlog << "< " << current_symbol->get_name() << " : " << current_symbol->get_type() << " >" << endl;

            string symbol_kind = current_symbol->get_symbol_kind();

            if (symbol_kind == "variable")
            {
                outlog << "Variable" << endl;
                outlog << "Type: " << current_symbol->get_data_type() << endl;
                outlog << endl;
            }
            else if (symbol_kind == "array")
            {
                outlog << "Array" << endl;
                outlog << "Type: " << current_symbol->get_data_type() << endl;
                outlog << "Size: " << current_symbol->get_arr_size() << endl;
                outlog << endl;
            }
            else if (symbol_kind == "function")
            {
                outlog << "Function Definition" << endl;
                outlog << "Return Type: " << current_symbol->get_data_type() << endl;
                outlog << "Number of Parameters: " << current_symbol->get_func_no_of_parameters() << endl;
                outlog << "Parameter Details: ";

                vector<string> parameter_types = current_symbol->get_func_parameter_types();
                vector<string> parameter_names = current_symbol->get_func_parameter_names();

                for (int i = 0; i < current_symbol->get_func_no_of_parameters(); i++)
                {
                    if (i != 0)
                    {
                        outlog << ", ";
                    }

                    outlog << parameter_types[i] << " " << parameter_names[i];
                }

                outlog << endl;
            }
        }
    }

    
    void print_scope_table(ofstream& outlog)
    {
        outlog << "ScopeTable # "+ to_string(unique_id) << endl;

        for (int i = 0; i < bucket_count; i++)
        {
            if (table[i].empty())
            {
                continue;
            }

            outlog << i << " --> " << endl;

            helper_print_symbol_list(table[i], outlog);
        }

        outlog << endl;
    }





    // removes all symblos from the chain
    void helper_delete_symbol_list(list<symbol_info *> &symbol_list_in_a_scope_idx)
    {
        for (auto it = symbol_list_in_a_scope_idx.begin(); it != symbol_list_in_a_scope_idx.end(); it++)
        {
            delete *it;
        }

        symbol_list_in_a_scope_idx.clear();
    }

    ~scope_table()
    {
        for (int i = 0; i < bucket_count; i++)
        {
            helper_delete_symbol_list(table[i]);
        }

        table.clear();
    }

    // you can add more methods if you need
};

// complete the methods of scope_table class
// void scope_table::print_scope_table(ofstream& outlog)
// {
//     outlog << "ScopeTable # "+ to_string(unique_id) << endl;

//     //iterate through the current scope table and print the symbols and all relevant information
// }
