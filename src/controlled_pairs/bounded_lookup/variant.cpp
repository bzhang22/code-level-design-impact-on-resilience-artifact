#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
// Same result read from a precomputed 256-entry lookup table (prime).
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"0\n"; return 0; }
    int tbl[256]; for(int k=0;k<256;k++) tbl[k]=(k*k)%97;
    long long s=0; int n=(int)v.size();
    for(int i=0;i<n;i++){ int r=v[i]&255; s += (long long)tbl[r]; }
    cout << s << "\n";
    return 0;
}
