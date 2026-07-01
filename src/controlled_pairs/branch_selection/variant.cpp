#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
// Array maximum with a control BRANCH (baseline).
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"0\n"; return 0; }
    int mx = v[0]; int n=(int)v.size();
    for(int i=1;i<n;i++){
        if(v[i] > mx) mx = v[i];        // branch decides the update
    }
    cout << mx << "\n";
    return 0;
}
