// DNA motif search: count exact occurrences of a pattern in a 4-symbol text.
// BASELINE: per-position nonzero-FLAG verdict, full scan. reads numbers.txt:
// v[0]=m, pattern=v[1..m], text=rest. output: match count.
#include <cstdio>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ printf("0\n"); return 0; }
    int m=v[0]; if(m<1||(int)v.size()<1+m){ printf("0\n"); return 0; }
    vector<int> pat(v.begin()+1,v.begin()+1+m), text(v.begin()+1+m,v.end());
    int n=(int)text.size(); long long cnt=0;
    for(int i=0;i+m<=n;++i){
        int hit=1;
        for(int j=0;j<m;++j) if(text[i+j]!=pat[j]) hit=0;   // flag, full scan
        if(hit) cnt++;
    }
    printf("%lld\n",cnt);
    return 0;
}
