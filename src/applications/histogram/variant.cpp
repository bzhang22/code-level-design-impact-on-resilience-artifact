#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"\n"; return 0; }
    int tbl[256]; for(int k=0;k<256;k++) tbl[k]=(k*k)%97;
    long long bin[97]; for(int k=0;k<97;k++) bin[k]=0;
    int n=(int)v.size();
    for(int i=0;i<n;i++){ int r=v[i]&255; int t=tbl[r]; bin[t]++; }
    for(int k=0;k<97;k++) cout<<bin[k]<<" ";
    cout<<"\n";
    return 0;
}
