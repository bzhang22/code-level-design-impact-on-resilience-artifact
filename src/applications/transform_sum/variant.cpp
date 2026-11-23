#include <cstdio>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    int T[256]; for(int k=0;k<256;k++) T[k]=(k*k*k)%251;
    int n=(int)v.size(); long long s=0;
    for(int i=0;i<n;i++){ int r=v[i]&255; s += (long long)T[r]; }
    printf("%lld\n",s);
    return 0;
}
