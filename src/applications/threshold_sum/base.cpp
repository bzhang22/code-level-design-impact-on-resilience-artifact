#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"0\n"; return 0; }
    int n=(int)v.size();
    long long acc=0;
    for(int i=0;i<n;i++){
        int w=(n*7+13)%9973;
        if(v[i] > 500000) acc += (long long)v[i]*w;
    }
    cout<<acc<<"\n";
    return 0;
}
