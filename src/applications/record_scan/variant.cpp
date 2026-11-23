#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x; while(f>>x) v.push_back(x); f.close();
    const int W=4; int n=(int)v.size(); int recs=n/W;
    int tbl[1024]; for(int i=0;i<1024;i++) tbl[i]=(i*i)%769;
    long long K = ((long long)recs*2654435761LL + 1) % 1000003;
    long long s=0, cnt=0;
    for(int r=0;r<recs;r++){
        int xx = v[r*W] & 1023;
        s += (long long)tbl[xx] * K;
        int mc=0;
        for(int c=0;c<W;c++) if((v[r*W+c] % 4) != 3) mc++;
        if(mc==W) cnt++;
    }
    cout << s << " " << cnt << "\n"; return 0; }
