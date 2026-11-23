#include <cstdio>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ printf("0\n"); return 0; }
    int mx=v[0]; int n=(int)v.size();
    for(int i=1;i<n;i++){ int xi=v[i]; int d=xi-mx; mx=xi-(d&(d>>31)); }
    printf("%d\n",mx);
    return 0;
}
