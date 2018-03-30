#include<iostream>
#include<string>
#include "encrypt.h"

using namespace std;




string encrypt::ShuffleEncrypt(const std::string &sub, const std::string &inMessage)
{
	std::string outString; 

	for(int i = 0; i < inMessage.size(); i++)
	{
		if(inMessage.at(i) >= 'A' && inMessage.at(i) <= 'Z')
			outString.push_back(sub.at(inMessage.at(i)-'A'));
		else
			outString.push_back(inMessage.at(i));
	}
	return outString;
}

string encrypt::ShuffleDecrypt(const std::string &sub, const std::string &inMessage)
{
	std::string outString; 

	for(int i = 0; i < inMessage.size(); i++)
	{
		if(inMessage.at(i) >= 'A' && inMessage.at(i) <= 'Z')
		{
			int j;
			for(j = 0; j < sub.size(); j++)
			{
				if(sub.at(j) == inMessage.at(i))
					break;
			}

			outString.push_back(char(j+'A'));
		}
		else
			outString.push_back(inMessage.at(i));
	}
	return outString;
}




char encrypt::toUpper(char ch) {
  if(ch > 96 && ch < 123)
    ch = ch - 32;
  return ch;
}

char encrypt::toLower(char ch) {
  if(ch > 64 && ch < 91)
    ch = ch + 32;
  return ch;
}


string entrypt::TransEncrypt(string plaintext, string key) {
  int rows, columns;
  const int  size = plaintext.length();
  columns = key.length();
  rows = (size % columns) == 0 ? size / columns : size / columns + 1;
  char cipher[size + 10];
  int i, count = 0, j;
  // Building up the matrix
  char **matrix = new char*[rows];

  for(i = 0; i < rows; i++)
    matrix[i] = new char[columns];

  //cout << " Filling matrix with letters of message\n";
  for(i = 0; i < size; i++)
    matrix[i/columns][i%columns] = plaintext.at(i);

  while(i < rows*columns) {
    matrix[i/columns][i%columns] = 'X';
    i++;
  }

  Curses_printMatrix(matrix, key, rows, columns, 9, 3);
  //printMatrix(matrix, key, rows, columns);
  //cout << " Sorting columns on the basis of keyword\n";
  for(i = 0; i < columns; i++) {
    for(j = 0; j < i; j++) {
      if(toLower(key[i]) < toLower(key[j])) {
        swap(key, i, j);
        swapColumns(matrix, i, j, rows);
      }
    }
  }
  //printMatrix(matrix, key, rows, columns);
  //cout << "filling cipher ...\n";
  count = 0;
  for(i = 0; i < columns; i++) {
    for(j = 0; j < rows; j++) {
      cipher[count++] = matrix[j][i];
    }
  }
  freeMatrix(matrix, rows, columns);
  return string(cipher, count);
}

string TransDecrypt(string ciphertext, string key) {
  int rows, columns;
  const int size = ciphertext.length();
  columns = key.length();
  rows = (size % columns) == 0 ? size / columns : size / columns + 1;
  int i, j, count = 0, k, rank;
  char plain[size + 10];
  string temp(key);

  //cout << " Building up the matrix \n";
  char **matrix = new char*[rows];
  for(i = 0; i < rows; i++)
    matrix[i] = new char[columns];

  for(i = 0; i < columns; i++) {
    rank = determineRank(key, i, key.length());
    count = rank*rows;

    for(j = 0; j < rows; j++) {
      matrix[j][i] = ciphertext.at(count++);
    }
  }

  //printMatrix(matrix, key, rows, columns);
  Curses_printMatrix(matrix, key, rows, columns, 30, 30);

  // Reading columns
  count = 0;
  for(i = 0; i < rows; i++)
    for(j = 0; j < columns; j++)
      plain[count++] = matrix[i][j];
  while(plain[count-1] == 'X')
    count--;
  freeMatrix(matrix, rows, columns);
  return string(plain, count);
}

void entrypt::swap(string& key, int i, int j) {
  char tmp = key[i];
  key[i] = key[j];
  key[j] = tmp;
}

void encrypt::swapColumns(char **matrix, int i, int j, int rows) {
  char *tmp = new char[rows];
  int ii;

  for(ii = 0; ii < rows; ii++)
    tmp[ii] = matrix[ii][i];
  for(ii = 0; ii < rows; ii++)
    matrix[ii][i] = matrix[ii][j];
  for(ii = 0; ii < rows; ii++)
    matrix[ii][j] = tmp[ii];
}

void encrypt::freeMatrix(char **matrix, int rows, int columns) {
  int ii;
  for(ii = 0; ii < rows; ii++)
    delete matrix[ii];
  delete matrix;
}

int encrypt::determineRank(string str, int index, int size) {
  char tmp = str[index], temp;
  int i, j;

  for(i = 0; i < size; i++) {
    for(j = 0; j < i; j++) {
      if(toLower(str[i]) < toLower(str[j])) {
        temp = str[i];
        str[i] = str[j];
        str[j] = temp;
      }
    }
  }

  for(i = 0; i < size; i++)
    if(str[i] == tmp)
      return i;

  return -1;
}

void encrypt::printMatrix(char **matrix, string key, int rows, int columns) {
  int i, j;
  for(i = 0; i < key.length(); i++)
    cout << key[i] << " ";
  cout << endl;
  cout << "=========================================\n";
  for(i = 0; i < rows; i++) {
    for(j = 0; j < columns; j++)
      cout << matrix[i][j] << " ";
    cout << "\n";
  }
}
  
void entrypt::Curses_printMatrix(char **matrix, string key, int rows, int columns, int r, int c) {
  int i, j;
  move(r, c);
  for(i = 0; i < key.length(); i++)
    printw("%c ", key.at(i));
  r++;
  mvprintw(r, c, "========================");
  for(i = 0; i < rows; i++) {
    move(++r, c);
    for(j = 0; j < columns; j++)
      printw("%c ", matrix[i][j]);
  }
}

int encrypt::powerExponentiationModulus(int base, int exponent, int modulo) {
  const int size = logbase2(exponent);
  //cout << "size : " << size << endl;
  int *array = new int[size];
  int i, res = 1;
  array[0] = base % modulo;
  //cout << base << "^" << power(2, 0) << " mod " << modulo << " = "
  //     << array[0] << endl;
  for(i = 1; sumExp(array, i) <= exponent; i++) {
    array[i] = (array[i-1]*array[i-1]) % modulo;
    //cout << base << "^" << power(2, i) << " mod " << modulo << " = "
    //     << array[i] << endl;
  }
  //cout << "res : (";
  for(; i >= 0; i--) {
    if(exponent & power(2, i)) {
      //cout << array[i] << " * ";
      res *= array[i];
    }
  }
  //cout << "\b\b) mod " << modulo << endl;

  return res % modulo;
}













string encrypt::VernamEncrypt(string plaintext, string key) {
  int i;
  if(key.length() != plaintext.length()) {
    cout << "ERROR: Key's length has to be equal to plaintext's length";
    return "";
  }
  for(i = 0; i < plaintext.length(); i++)
    plaintext.at(i) = plaintext.at(i) ^ key.at(i);
  return plaintext;
}

string encrypt::VernamDecrypt(string ciphertext, string key) {
  int i;
  if(key.length() != ciphertext.length()) {
    cout << "ERROR: Key's length has to be equal to plaintext's length";
    return "";
  }
  for(i = 0; i < ciphertext.length(); i++)
    ciphertext.at(i) = ciphertext.at(i) ^ key.at(i);
  return ciphertext;
}

