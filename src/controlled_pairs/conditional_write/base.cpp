#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
// Compare-exchange via BRANCHLESS min/max, writing both slots every step (A=typical).
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x;
    while(f>>x && (int)v.size()<50000) v.push_back(x); f.close();
    int n=(int)v.size(); const int P=300;
    for(int p=0;p<P;p++)
      for(int j=0;j+1<n;j++){ int a=v[j],b=v[j+1],d=a-b,m=d&(d>>31); v[j]=b+m; v[j+1]=a-m; }
    long long chk=0; for(int i=0;i<n;i++) chk=chk*1000003+v[i];
    cout<<chk<<"\n"; return 0; }
