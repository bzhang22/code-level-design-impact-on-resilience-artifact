#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
// Loop-invariant recomputed INSIDE the loop (baseline).
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"0\n"; return 0; }
    long long s=0; int n=(int)v.size();
    for(int i=0;i<n;i++){
        int m = (n*7 + 13) % 97;        // invariant, recomputed every iteration
        s += (long long)v[i] * m;
    }
    cout << s << "\n";
    return 0;
}
