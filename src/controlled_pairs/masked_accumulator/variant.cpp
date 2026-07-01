#include <iostream>
#include <vector>
#include <fstream>
using namespace std;
// Same rolling hash in a WIDE accumulator, masked once at the end (B=insight):
// high-bit flips are removed by the final &255.
int main(){
    vector<int> v; ifstream f("numbers.txt"); int x; while(f>>x) v.push_back(x); f.close();
    int n=(int)v.size(); unsigned long long h=0;
    for(int i=0;i<n;i++) h = h*131 + (unsigned long long)(v[i]&255);
    cout<<(int)(h & 255)<<"\n"; return 0; }
