#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
// Array maximum computed BRANCHLESS via arithmetic (prime). Same output as ctrl_b_base.
// max(mx,x): diff=x-mx; if diff<0 (x<mx) -> (diff>>31)=-1 -> mx=x-diff=mx; else mx=x.
// Inputs are bounded (0..10^6) so diff does not overflow.
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"0\n"; return 0; }
    int mx = v[0]; int n=(int)v.size();
    for(int i=1;i<n;i++){
        int xi = v[i];
        int diff = xi - mx;
        mx = xi - (diff & (diff >> 31));   // branchless max, no control branch
    }
    cout << mx << "\n";
    return 0;
}
