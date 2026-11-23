#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"0\n"; return 0; }
    long long s=0; int n=(int)v.size();
    int m = (n*7 + 13) % 97;
    for(int i=0;i<n;i++){
        s += (long long)v[i] * m;
    }
    cout << s << "\n";
    return 0;
}
