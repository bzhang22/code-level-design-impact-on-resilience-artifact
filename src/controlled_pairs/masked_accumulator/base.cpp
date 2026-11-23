#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x; while(f>>x) v.push_back(x); f.close();
    int n=(int)v.size(); unsigned char h=0;
    for(int i=0;i<n;i++) h = (unsigned char)(h*131 + (v[i]&255));
    cout<<(int)h<<"\n"; return 0; }
