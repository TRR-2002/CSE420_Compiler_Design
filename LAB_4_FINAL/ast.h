#ifndef AST_H
#define AST_H

#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <map>

using namespace std;

class ASTNode {
public:
    virtual ~ASTNode() {}
    virtual string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp, int& temp_count, int& label_count) const = 0;
};

// Expression node types

class ExprNode : public ASTNode {
protected:
    string node_type; // Type information (int, float, void, etc.)
public:
    ExprNode(string type) : node_type(type) {}
    virtual string get_type() const { return node_type; }
};

// Variable node (for ID references)

class VarNode : public ExprNode {
private:
    string name;
    ExprNode* index; // For array access, nullptr for simple variables

public:
    VarNode(string name, string type, ExprNode* idx = nullptr)
        : ExprNode(type), name(name), index(idx) {}
    
    ~VarNode() { if(index) delete index; }
    
    bool has_index() const { return index != nullptr; }
    

    // gonna handel arrays
    string generate_index_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                              int& temp_count, int& label_count) const {
        // TODO: Implement this method
        // Should generate code to calculate the array index and return the temp variable
        


        // checking if the node which contains index is not null
        if (index) {
            // Generate code for the index expression
            string idx_temp = index->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );
            // calling gen code for the index
            //t0 = 5



            // Scale the index based on element type (4 bytes for int, 8 bytes for float/double)
            string scale_temp = "t" + to_string(temp_count);
            temp_count = temp_count + 1;


            int scale_factor = 4; // Default for int and most types

            if (node_type == "float" || node_type == "double") {
                scale_factor = 8; // 8 bytes for float/double
            }

            outcode << scale_temp << " = " << idx_temp << " * " << scale_factor << endl;
            //t1 = t0 * scale_factor



            return scale_temp;
            //return t1
        }

        return "";
    }
    



    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for variable access or array access
        // map if t0 = a, t2 = b
        // <<t0,a>,< t2,b>>




        string temp = "t" + to_string(temp_count);
        temp_count = temp_count + 1;
        // got t2


        //checking that if it has index 
        // if index then array
        if (index) {
            // For array access, generate scaled index code
            string scaled_idx = generate_index_code(
                outcode, symbol_to_temp, temp_count, label_count
            );
            outcode << temp << " = " << name << "[" << scaled_idx << "]" << endl;
            // t2 = arr[t1]



        } else {
            // Simple variable access
            if (symbol_to_temp.find(name) != symbol_to_temp.end()) {
                return symbol_to_temp[name]; // Return existing temp if variable already loaded
                // if mapping already exists then return the temp variable



            }
            outcode << temp << " = " << name << endl;
            symbol_to_temp[name] = temp;
            // if mapping does not exist then create a new mapping for the variable and temp variable
        }

        return temp;
    }
    
    string get_name() const { return name; }
};

// Constant node

class ConstNode : public ExprNode {
private:
    string value;

public:
    ConstNode(string val, string type) : ExprNode(type), value(val) {}
    // if a = 1 then the value is 1 and the type is int
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        
        //outcode is for the output file 
        // map  symbol_to_temp ???
        // temo_count gets the integer part of t0,t1,t2 etc
        //
        
        // TODO: Implement this method
        // Should generate code for constant values

        string temp = "t" + to_string(temp_count);
        // adding the int part to the t

        temp_count = temp_count + 1;
        // increasing the count for next use 

        outcode << temp << " = " << value << endl;
        // t0 = 1

        return temp;
        // return "";
    }
};

// Binary operation node

class BinaryOpNode : public ExprNode {
private:
    string op;
    ExprNode* left;
    ExprNode* right;

public:
    BinaryOpNode(string op, ExprNode* left, ExprNode* right, string result_type)
        : ExprNode(result_type), op(op), left(left), right(right) {}
    
    ~BinaryOpNode() {
        delete left;
        delete right;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for binary operations

        string left_temp = left->generate_code(
            outcode, symbol_to_temp, temp_count, label_count
        );

        string right_temp = right->generate_code(
            outcode, symbol_to_temp, temp_count, label_count
        );

        string temp = "t" + to_string(temp_count);
        temp_count = temp_count + 1;

        outcode << temp << " = " << left_temp << " "
                << op << " " << right_temp << endl;
        // Example: t2 = t0 + t1

        return temp;
    }
};

// Unary operation node

class UnaryOpNode : public ExprNode {
private:
    string op;
    ExprNode* expr;

public:
    UnaryOpNode(string op, ExprNode* expr, string result_type)
        : ExprNode(result_type), op(op), expr(expr) {}
    
    ~UnaryOpNode() { delete expr; }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for unary operations

        string expr_temp = expr->generate_code(
            outcode, symbol_to_temp, temp_count, label_count
        );

        string temp = "t" + to_string(temp_count);
        temp_count = temp_count + 1;

        outcode << temp << " = " << op << expr_temp << endl;
        // Example: t1 = -t0

        return temp;
    }
};

// Assignment node

class AssignNode : public ExprNode {
private:
    VarNode* lhs;
    ExprNode* rhs;

public:
    AssignNode(VarNode* lhs, ExprNode* rhs, string result_type)
        : ExprNode(result_type), lhs(lhs), rhs(rhs) {}
    
    ~AssignNode() {
        delete lhs;
        delete rhs;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for assignment operations

        string rhs_temp = rhs->generate_code(
            outcode, symbol_to_temp, temp_count, label_count
        );

        if (lhs->has_index()) {
            string scaled_idx = lhs->generate_index_code(
                outcode, symbol_to_temp, temp_count, label_count
            );

            outcode << lhs->get_name() << "[" << scaled_idx
                    << "] = " << rhs_temp << endl;
        } else {
            outcode << lhs->get_name() << " = " << rhs_temp << endl;
            symbol_to_temp[lhs->get_name()] = rhs_temp;
        }

        return rhs_temp;
    }
};

// Statement node types

class StmtNode : public ASTNode {
public:
    virtual string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                                int& temp_count, int& label_count) const = 0;
};

// Expression statement node

class ExprStmtNode : public StmtNode {
private:
    ExprNode* expr;

public:
    ExprStmtNode(ExprNode* e) : expr(e) {}
    ~ExprStmtNode() { if(expr) delete expr; }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for expression statements
        // Example: a = b + 1;
        // An empty statement like ; generates no code

        if (expr) {
            return expr->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );
        }

        return "";
    }
};

// Block (compound statement) node

class BlockNode : public StmtNode {
private:
    vector<StmtNode*> statements;

public:
    ~BlockNode() {
        for (auto stmt : statements) {
            delete stmt;
        }
    }
    
    void add_statement(StmtNode* stmt) {
        if (stmt) statements.push_back(stmt);
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for all statements in the block

        // Example: { int a; a = 5; return a; }
        // Generate each statement inside the block in order
        for (auto stmt : statements) {
            if (stmt) {
                stmt->generate_code(
                    outcode, symbol_to_temp, temp_count, label_count
                );
            }
        }

        return "";
    }
};

// If statement node

class IfNode : public StmtNode {
private:
    ExprNode* condition;
    StmtNode* then_block;
    StmtNode* else_block; // nullptr if no else part

public:
    IfNode(ExprNode* cond, StmtNode* then_stmt, StmtNode* else_stmt = nullptr)
        : condition(cond), then_block(then_stmt), else_block(else_stmt) {}
    
    ~IfNode() {
        delete condition;
        delete then_block;
        if (else_block) delete else_block;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for if-else statements


        /*
        if (a > b) a = 1; else a = 2;
        
        t2 = t0 > t1
        if t2 goto L0
        goto L1

        L0:
        a = 1
        goto L2

        L1:
        a = 2

        L2:
        
        */



        string condition_temp = condition->generate_code(
            outcode, symbol_to_temp, temp_count, label_count
        );

        // Both branches start with the same variable-to-temporary mappings
        map<string, string> branch_entry_map = symbol_to_temp;

        string then_label = "L" + to_string(label_count);
        label_count = label_count + 1;

        string else_label = "L" + to_string(label_count);
        label_count = label_count + 1;

        string end_label = "L" + to_string(label_count);
        label_count = label_count + 1;

        


        outcode << "if " << condition_temp << " goto " << then_label << endl;
        outcode << "goto " << else_label << endl;
        outcode << then_label << ":" << endl;

        map<string, string> then_symbol_to_temp = branch_entry_map;

        if (then_block) {
            then_block->generate_code(
                outcode, then_symbol_to_temp, temp_count, label_count
            );
        }

        outcode << "goto " << end_label << endl;



        
        outcode << else_label << ":" << endl;

        map<string, string> else_symbol_to_temp = branch_entry_map;

        if (else_block) {
            else_block->generate_code(
                outcode, else_symbol_to_temp, temp_count, label_count
            );
        }

        outcode << end_label << ":" << endl;

        // Keep only mappings that are identical after both possible branches
        symbol_to_temp.clear();

        for (const auto& mapping : then_symbol_to_temp) {
            auto else_mapping = else_symbol_to_temp.find(mapping.first);

            if (else_mapping != else_symbol_to_temp.end() &&
                else_mapping->second == mapping.second) {
                symbol_to_temp[mapping.first] = mapping.second;
            }
        }

        return "";
    }
};

// While statement node

class WhileNode : public StmtNode {
private:
    ExprNode* condition;
    StmtNode* body;

public:
    WhileNode(ExprNode* cond, StmtNode* body_stmt)
        : condition(cond), body(body_stmt) {}
    
    ~WhileNode() {
        delete condition;
        delete body;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for while loops

        /*
        while (a < 5) {
            a = a + 1;
        }

        L0:
        t2 = t0 < t1
        if t2 goto L1
        goto L2
        L1:
        t4 = t0 + t3
        a = t4
        goto L0
        L2:
        */

        string condition_label = "L" + to_string(label_count);
        label_count = label_count + 1;

        string body_label = "L" + to_string(label_count);
        label_count = label_count + 1;

        string end_label = "L" + to_string(label_count);
        label_count = label_count + 1;






        outcode << condition_label << ":" << endl;

        string condition_temp = condition->generate_code(
            outcode, symbol_to_temp, temp_count, label_count
        );

        outcode << "if " << condition_temp << " goto " << body_label << endl;
        outcode << "goto " << end_label << endl;



        

        outcode << body_label << ":" << endl;

        if (body) {
            body->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );
        }

        outcode << "goto " << condition_label << endl;
        outcode << end_label << ":" << endl;

        return "";
    }
};

// For statement node

class ForNode : public StmtNode {
private:
    ExprNode* init;
    ExprNode* condition;
    ExprNode* update;
    StmtNode* body;

public:
    ForNode(ExprNode* init_expr, ExprNode* cond_expr, ExprNode* update_expr, StmtNode* body_stmt)
        : init(init_expr), condition(cond_expr), update(update_expr), body(body_stmt) {}
    
    ~ForNode() {
        if (init) delete init;
        if (condition) delete condition;
        if (update) delete update;
        delete body;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for for loops

        /*
        for (i = 0; i < 10; i++) {
            a = a + 1;
        }

        The initialization runs once before the loop:
        t0 = 0
        i = t0
        */

        if (init) {
            init->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );
        }

        // Reload variables when generating the loop condition and body
        symbol_to_temp.clear();

        string condition_label = "L" + to_string(label_count);
        label_count = label_count + 1;

        string body_label = "L" + to_string(label_count);
        label_count = label_count + 1;

        string end_label = "L" + to_string(label_count);
        label_count = label_count + 1;

        /*
        For the condition i < 10:

        L0:
        t2 = i < 10
        if t2 goto L1
        goto L2
        */

        outcode << condition_label << ":" << endl;

        if (condition) {
            string condition_temp = condition->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );

            outcode << "if " << condition_temp << " goto " << body_label << endl;
            outcode << "goto " << end_label << endl;
        } else {
            // No condition means an infinite loop, for example: for (;;)
            outcode << "goto " << body_label << endl;
        }

        outcode << body_label << ":" << endl;

        if (body) {
            body->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );
        }

        if (update) {
            update->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );
        }

        outcode << "goto " << condition_label << endl;
        outcode << end_label << ":" << endl;

        return "";
    }
};

// Return statement node

class ReturnNode : public StmtNode {
private:
    ExprNode* expr;

public:
    ReturnNode(ExprNode* e) : expr(e) {}
    ~ReturnNode() { if (expr) delete expr; }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for return statements

        /*
        return a + b;

        t2 = t0 + t1
        return t2
        */

        if (expr) {
            string return_temp = expr->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );

            outcode << "return " << return_temp << endl;
        } else {
            // Handles an empty return statement: return;
            outcode << "return" << endl;
        }

        return "";
    }
};

// Declaration node

class DeclNode : public StmtNode {
private:
    string type;
    vector<pair<string, int>> vars; // Variable name and array size (0 for regular vars)
    //if int a,b,c,arr[100]
    //<<a, 0>>, <<b, 0>>, <<c, 0>>, <<arr, 100>>
public:
    DeclNode(string t) : type(t) {}
    
    void add_var(string name, int array_size = 0) {
        vars.push_back(make_pair(name, array_size));
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for variable declarations

        for (auto& var : vars) {
        // for loop for vars

            outcode << "// Declaration: " << type << " " << var.first; // var.first is the variable name like a,b...
            if (var.second > 0) {
            // var.second is size 

                outcode << "[" << var.second << "]";
            }

            outcode << endl;
        }

        return "";
    }
    
    string get_type() const { return type; }
    const vector<pair<string, int>>& get_vars() const { return vars; }
};

// Function declaration node

class FuncDeclNode : public ASTNode {
private:
    string return_type;
    string name;
    vector<pair<string, string>> params; // Parameter type and name
    BlockNode* body;

public:
    FuncDeclNode(string ret_type, string n) : return_type(ret_type), name(n), body(nullptr) {}
    ~FuncDeclNode() { if (body) delete body; }
    
    void add_param(string type, string name) {
        params.push_back(make_pair(type, name));
    }
    
    void set_body(BlockNode* b) {
        body = b;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for function declarations

        /*
        int func(int a, int b) {
            return a + b;
        }

        // Function: int func(int a, int b)
        t0 = a
        t1 = b
        t2 = t0 + t1
        return t2
        */

        // A new function needs its own variable-to-temporary mapping
        symbol_to_temp.clear();

        outcode << "// Function: " << return_type << " " << name << "(";

        for (int i = 0; i < params.size(); i = i + 1) {
            outcode << params[i].first << " " << params[i].second;

            if (i < params.size() - 1) {
                outcode << ", ";
            }
        }

        outcode << ")" << endl;

        if (body) {
            body->generate_code(
                outcode, symbol_to_temp, temp_count, label_count
            );
        }

        outcode << endl;
        return "";
    }
};

// Helper class for function arguments

class ArgumentsNode : public ASTNode {
private:
    vector<ExprNode*> args;

public:
    ~ArgumentsNode() {
        // Don't delete args here - they'll be transferred to FuncCallNode
    }
    
    void add_argument(ExprNode* arg) {
        if (arg) args.push_back(arg);
    }
    
    ExprNode* get_argument(int index) const {
        if (index >= 0 && index < args.size()) {
            return args[index];
        }
        return nullptr;
    }
    
    size_t size() const {
        return args.size();
    }
    
    const vector<ExprNode*>& get_arguments() const {
        return args;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // This node doesn't generate code directly
        return "";
    }
};

// Function call node

class FuncCallNode : public ExprNode {
private:
    string func_name;
    vector<ExprNode*> arguments;

public:
    FuncCallNode(string name, string result_type)
        : ExprNode(result_type), func_name(name) {}
    
    ~FuncCallNode() {
        for (auto arg : arguments) {
            delete arg;
        }
    }
    
    void add_argument(ExprNode* arg) {
        if (arg) arguments.push_back(arg);
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for function calls

        /*
        c = func(a, b);

        t0 = a
        param t0
        t1 = b
        param t1
        t2 = call func, 2
        c = t2
        */

        // Function arguments are loaded into fresh temporary variables
        map<string, string> argument_symbol_to_temp;

        for (auto argument : arguments) {
            string argument_temp = argument->generate_code(
                outcode, argument_symbol_to_temp, temp_count, label_count
            );

            outcode << "param " << argument_temp << endl;
        }

        string result_temp = "t" + to_string(temp_count);
        temp_count = temp_count + 1;

        outcode << result_temp << " = call " << func_name
                << ", " << arguments.size() << endl;

        return result_temp;
    }
};

// Program node (root of AST)

class ProgramNode : public ASTNode {
private:
    vector<ASTNode*> units;

public:
    ~ProgramNode() {
        for (auto unit : units) {
            delete unit;
        }
    }
    
    void add_unit(ASTNode* unit) {
        if (unit) units.push_back(unit);
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for the entire program

        for (auto unit : units) {
            if (unit) {
                unit->generate_code(
                    outcode, symbol_to_temp, temp_count, label_count
                );
            }
        }

        return "";
    }
};

#endif // AST_H
