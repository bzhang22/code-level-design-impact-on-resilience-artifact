#include <cstdio>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    int n=(int)v.size(); long long s=0;
    for(int i=0;i<n;i++){ int r=v[i]&255; s += (long long)((r*r*r)%251); }
    printf("%lld\n",s);
    return 0;
}
