#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <cmath>

using namespace std;

vector<string> ReadMsg(string file) {
    vector<string> messages;
    ifstream input(file);
    if (!input) {
        cout << "Khong mo duoc file input: " << file << '\n';
        return messages;
    }
    string line;
    while (getline(input, line)) {
        if (!line.empty()) {
            messages.push_back(line);
        }
    }
    return messages;
}

void WriteLenMsg(const vector<int>& len_msg, string file) {
    ofstream output(file);
    if (!output) {
        cout << "Khong mo duoc file output: " << file << '\n';
        return;
    }
    for (int len : len_msg) {
        output << hex << len << '\n';
    }
    return;
}

void writeBlocks(const vector<string>& messages, string file) {
    ofstream output(file);
    if (!output) {
        cout << "Khong mo duoc file output: " << file << '\n';
        return;
    }

    for (int i = 0; i < messages.size(); i++) {
        output << "//Testcase " << i + 1 << '\n';
        for (int j = 0; j < messages[i].size(); j += 128) {
            string block = messages[i].substr(j, 128);
            output << block << '\n';
        }
    }
    return;
}

vector<int> NumBlock(vector<int>& len_msg) {
    vector<int> num_block(len_msg.size());
    for (int i = 0; i < len_msg.size(); i++) {
        num_block[i] = (len_msg[i] + 1 + 64 + 511) / 512;
    }
    return num_block;
}

void PaddingMsg(vector<string>& messages, const vector<int>& len_msg, int mode) {
    for (size_t i = 0; i < messages.size(); i++) {
        if (messages[i] == "00"){
            messages[i] = "80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
            continue;
        }
        string hex_msg;
        if (mode == 1) {
            string msg = messages[i];
            hex_msg.reserve(msg.size() * 2);
            for (unsigned char c : msg) {
                stringstream ss;
                ss << hex << setw(2) << setfill('0') << static_cast<int>(c);
                hex_msg += ss.str();
            }
        } else {
            hex_msg = messages[i];
        }
        
        hex_msg += "80";
        while ((hex_msg.size() % 128) != 112) {         // để lại 64 bit cuối ghi độ dài Msg.
            hex_msg += "00";
        }
        // độ dài 512 bit <=> 128 kí tự.

        unsigned long long bit_len = len_msg[i];
        string len_hex = "";
        int x = 0xF;
        for (int i = 0; i < 16; i++) {
            string s;
            int tmp;
            tmp = (bit_len & x);
            s = (tmp < 10) ? to_string(tmp) : string(1, 'A' + tmp - 10);
            len_hex = s + len_hex;
            bit_len >>= 4;
        }
        hex_msg += len_hex;
        messages[i] = hex_msg;
    }
}

int main(){
    string inputMsg = "Msg.txt";
    string outputBlock = "Out_Block.txt";
    string outputNumBlock = "Out_NumBlock.txt";

    vector<string> messages = ReadMsg(inputMsg);

    int mode;
    cout << "Mode 1: Msg dang text, Mode 2: Msg dang hex\n";
    cout << "Nhap mode: ";
    cin >> mode;

    vector<int> len_msg(messages.size());
    for (int i = 0; i < messages.size(); i++) {
        len_msg[i] = messages[i].size() << 3;
    }
    vector<int> num_block = NumBlock(len_msg);
    WriteLenMsg(num_block, outputNumBlock);
    PaddingMsg(messages, len_msg, mode);
    writeBlocks(messages, outputBlock);
    cout << "So message doc duoc: " << messages.size() << '\n';
}
