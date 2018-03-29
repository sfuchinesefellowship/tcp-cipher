#include<string>

using namespace std;

class encrypt {
    public:
        encrypt();
        encrypt(int seg, int shift) : segment(seg), shift(shift) {};
        ~encrypt();
        string ShuffleEncrypt(string plaintext, int pos);
        string ShuffleDecrypt(string plaintext, int pos);

        string TransEncrypt(string plaintext, int key);
        string TransDecrypt(string plaintext, int key);
        string VernamEncrypt(string plaintext, int key);
        string VernamDecrypt(string plaintext, int key);
        char toLower(char ch);
        int MOD(int num);

    private:
        int segment; // The length of segment for split the plaintext
        int shift; // The shift of the characters to map a to

};

