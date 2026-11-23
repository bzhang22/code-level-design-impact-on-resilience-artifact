#include <iostream>
#include <vector>
#include <fstream>
using namespace std;

int main() {
    vector<int> v;
    ifstream file("numbers.txt");
    int x;
    while (file >> x) v.push_back(x);
    file.close();
    if (v.empty()) { cout << "\n"; return 0; }
    int m = v[0];
    if (m < 1 || (int)v.size() < 1 + m) { cout << "\n"; return 0; }
    vector<int> pat(v.begin() + 1, v.begin() + 1 + m);
    vector<int> text(v.begin() + 1 + m, v.end());

    int n = (int)text.size();
    for (int i = 0; i + m <= n; ++i) {
        int j = 0;
        while (j < m) {
            if (text[i + j] != pat[j]) break;
            ++j;
        }
        if (j == m) cout << i << " ";
    }
    cout << "\n";
    return 0;
}
