#include "scope_table.h"

class symbol_table
{
private:
    scope_table *current_scope;
    int bucket_count;
    int current_scope_id;

public:
    symbol_table(int bucket_count)
    {
        this->bucket_count = bucket_count;
        current_scope_id = 1;
        current_scope = new scope_table(bucket_count, current_scope_id, NULL);
    }

    ~symbol_table()
    {
        while (current_scope != NULL)
        {
            exit_scope();
        }
    }


    void enter_scope()
    {
        current_scope_id++;

        scope_table *new_scope = new scope_table(bucket_count, current_scope_id, current_scope);

        current_scope = new_scope;
    }


    bool helper_check_null(scope_table *scope, symbol_info *symbol, int n)
    {
        if (n == 0)
        {
            if (scope == NULL)
            {
                return true;
            }

            return false;
        }

        if (n == 1)
        {
            if (scope == NULL || symbol == NULL)
            {
                return true;
            }

            return false;
        }

        return false;
    }

    int get_current_scope_id()
    {
        if (helper_check_null(current_scope, NULL, 0))
        {
            return 0;
        }

        return current_scope->get_unique_id();
    }

    void exit_scope()
    {
        if (helper_check_null(current_scope, NULL, 0))
        {
            return;
        }

        scope_table *scope_to_delete = current_scope;
        current_scope = current_scope->get_parent_scope();
        delete scope_to_delete;
    }

    bool insert(symbol_info* symbol)
    {
        if (helper_check_null(current_scope, symbol, 1))
        {
            return false;
        }

        return current_scope->insert_in_scope(symbol);
    }

    bool remove(symbol_info* symbol)
    {
        if (helper_check_null(current_scope, symbol, 1))
        {
            return false;
        }

        return current_scope->delete_from_scope(symbol);
    }



    symbol_info* lookup(symbol_info* symbol)
    {
        if (helper_check_null(current_scope, symbol, 1))
        {
            return NULL;
        }

        scope_table *scope_to_search = current_scope;

        while (scope_to_search != NULL)
        {
            symbol_info *found_symbol = scope_to_search->lookup_in_scope(symbol);

            if (found_symbol != NULL)
            {
                return found_symbol;
            }

            scope_to_search = scope_to_search->get_parent_scope();
        }

        return NULL;
    }

    
    void print_current_scope(ofstream& outlog)
    {
        if (helper_check_null(current_scope, NULL, 0))
        {
            return;
        }

        current_scope->print_scope_table(outlog);
    }
    void print_all_scopes(ofstream& outlog)
    {
        outlog << "################################" << endl << endl;

        scope_table *temp = current_scope;

        while (temp != NULL)
        {
            temp->print_scope_table(outlog);
            temp = temp->get_parent_scope();
        }

        outlog << "################################" << endl << endl;
    }

    // you can add more methods if you need 
};

// complete the methods of symbol_table class


// void symbol_table::print_all_scopes(ofstream& outlog)
// {
//     outlog<<"################################"<<endl<<endl;
//     scope_table *temp = current_scope;
//     while (temp != NULL)
//     {
//         temp->print_scope_table(outlog);
//         temp = temp->get_parent_scope();
//     }
//     outlog<<"################################"<<endl<<endl;
// }
