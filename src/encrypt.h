#include<string>

using namespace std;

class encrypt {
    public:
        encrypt();
        encrypt(string _plaintext, string _key) : plaintext(_plaintext), key(_key) {};
        ~encrypt();
        string ShuffleEncrypt(string& subTable, string& plaintext);
        string ShuffleDecrypt(string& subTable, string& plaintext);

        string TransEncrypt(string plaintext, int key);
        string TransDecrypt(string plaintext, int key);
        string VernamEncrypt(string plaintext, int key);
        string VernamDecrypt(string plaintext, int key);
        
        char toUpper(char ch);

        char toLower(char ch);

        void swap(string& key, int i, int j);
        void swapColumns(char **matrix, int i, int j, int rows);
        void freeMatrix(char **matrix, int rows, int columns);
        int determineRank(string str, int index, int size);
        void printMatrix(char **matrix, string key, int rows, int columns)
        void Curses_printMatrix(char **matrix, string key, int rows, int columns, int r, int c);
        void powerExponentiationModulus(int base, int exponent, int modulo)
       

    private:

        string key;
        string plaintext;
        string cyphertext;
        string subTable = "ZYXWVUTSRQPONMLKJIHGFEDCBA";

};

