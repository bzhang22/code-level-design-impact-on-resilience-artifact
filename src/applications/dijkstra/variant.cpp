#include <cstdio>
#include <cstdlib>
#define NUM_NODES 100
#define NONE 9999
#define QCAP 400000
int AdjMatrix[NUM_NODES][NUM_NODES];
int dist_[NUM_NODES];
int qn[QCAP], qd[QCAP];

void run_dijkstra(int start){
    for(int c=0;c<NUM_NODES;c++) dist_[c]=NONE;
    dist_[start]=0;
    int qh=0, qt=0; qn[qt]=start; qd[qt]=0; qt++;
    while(qh<qt){
        int iNode=qn[qh], iDist=qd[qh]; qh++;
        for(int i=0;i<NUM_NODES;i++){
            int iCost=AdjMatrix[iNode][i];
            if(iCost!=NONE){
                if( (NONE==dist_[i]) || (dist_[i] > iCost+iDist) ){
                    dist_[i]=iDist+iCost;
                    if(qt<QCAP){ qn[qt]=i; qd[qt]=iDist+iCost; qt++; }
                }
            }
        }
    }
}

int main(){
    FILE* f=fopen("numbers.txt","r"); if(!f){ printf("0\n"); return 0; }
    for(int i=0;i<NUM_NODES;i++) for(int j=0;j<NUM_NODES;j++)
        if(fscanf(f,"%d",&AdjMatrix[i][j])!=1){ printf("0\n"); return 0; }
    fclose(f);
    unsigned long long chk=1469598103934665603ULL;
    for(int s=0;s<NUM_NODES;s++){
        run_dijkstra(s);
        for(int i=0;i<NUM_NODES;i++){ unsigned int u=(unsigned int)dist_[i]; chk=(chk^u)*1099511628211ULL; }
    }
    printf("%llu\n",chk);
    return 0;
}
