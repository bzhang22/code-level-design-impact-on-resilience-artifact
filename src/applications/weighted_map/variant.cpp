#include <cstdio>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    int n=(int)v.size(); long long s=0;
    int m=(n*7+13)%97;
    for(int i=0;i<n;i++){ s += (long long)v[i]*m; }
    printf("%lld\n",s);
    return 0;
}
