#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x) v.push_back(x); f.close();
    if(v.empty()){ cout<<"0\n"; return 0; }
    int m=v[0];
    if(m<1 || (int)v.size()<1+m){ cout<<"0\n"; return 0; }
    vector<int> pat(v.begin()+1, v.begin()+1+m);
    vector<int> text(v.begin()+1+m, v.end());
    int n=(int)text.size();
    long long cnt=0;
    for(int i=0;i+m<=n;++i){
        int mc=0;
        for(int j=0;j<m;++j) if(text[i+j]==pat[j]) mc++;
        if(mc==m) cnt++;
    }
    cout<<cnt<<"\n";
    return 0;
}
