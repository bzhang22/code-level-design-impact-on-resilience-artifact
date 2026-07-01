// Running maximum with a control BRANCH (resilient, Insight 4). Identical output to
// ev_peak_base: a fault in the branch leaves mx as some real element, not arbitrary math.
#include <cstdio>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ printf("0\n"); return 0; }
    int mx=v[0]; int n=(int)v.size();
    for(int i=1;i<n;i++){ if(v[i]>mx) mx=v[i]; }     // branch
    printf("%d\n",mx);
    return 0;
}
