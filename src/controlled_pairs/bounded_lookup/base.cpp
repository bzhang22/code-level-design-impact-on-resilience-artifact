#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
// Compute (r*r)%97 on the fly each iteration (baseline).
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"0\n"; return 0; }
    long long s=0; int n=(int)v.size();
    for(int i=0;i<n;i++){ int r=v[i]&255; s += (long long)((r*r)%97); }
    cout << s << "\n";
    return 0;
}
