// PARSEC blackscholes (Intel 2007), serial, adapted for the LLFI harness:
// reads option data from numbers.txt, prints a bit-checksum of all prices to stdout.
// BASELINE: faithful PARSEC control flow (branches in CNDF sign and put/call).
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <cstring>
typedef float fptype;
#define inv_sqrt_2xPI 0.39894228040143270286
#define NUM_RUNS 4

fptype CNDF( fptype InputX ) {
    int sign;
    fptype OutputX, xInput, xNPrimeofX, expValues, xK2, xK2_2, xK2_3, xK2_4, xK2_5;
    fptype xLocal, xLocal_1, xLocal_2, xLocal_3;
    if (InputX < 0.0) { InputX = -InputX; sign = 1; } else sign = 0;   // BRANCH (keep)
    xInput = InputX;
    expValues = exp(-0.5f * InputX * InputX);
    xNPrimeofX = expValues * inv_sqrt_2xPI;
    xK2 = 0.2316419 * xInput; xK2 = 1.0 + xK2; xK2 = 1.0 / xK2;
    xK2_2 = xK2*xK2; xK2_3 = xK2_2*xK2; xK2_4 = xK2_3*xK2; xK2_5 = xK2_4*xK2;
    xLocal_1 = xK2 * 0.319381530;
    xLocal_2 = xK2_2 * (-0.356563782);
    xLocal_3 = xK2_3 * 1.781477937;  xLocal_2 = xLocal_2 + xLocal_3;
    xLocal_3 = xK2_4 * (-1.821255978); xLocal_2 = xLocal_2 + xLocal_3;
    xLocal_3 = xK2_5 * 1.330274429;  xLocal_2 = xLocal_2 + xLocal_3;
    xLocal_1 = xLocal_2 + xLocal_1;
    xLocal = xLocal_1 * xNPrimeofX;  xLocal = 1.0 - xLocal;
    OutputX = xLocal;
    if (sign) { OutputX = 1.0 - OutputX; }                              // BRANCH (keep)
    return OutputX;
}

fptype BlkSchls( fptype sptprice, fptype strike, fptype rate, fptype volatility,
                 fptype time, int otype ) {
    fptype OptionPrice, xSqrtTime, logValues, xLogTerm, xD1, xD2, xPowerTerm, xDen;
    fptype d1, d2, FutureValueX, NofXd1, NofXd2, NegNofXd1, NegNofXd2;
    xSqrtTime = sqrt(time);
    logValues = log( sptprice / strike );
    xLogTerm = logValues;
    xPowerTerm = volatility * volatility; xPowerTerm = xPowerTerm * 0.5;
    xD1 = rate + xPowerTerm; xD1 = xD1 * time; xD1 = xD1 + xLogTerm;
    xDen = volatility * xSqrtTime; xD1 = xD1 / xDen; xD2 = xD1 - xDen;
    d1 = xD1; d2 = xD2;
    NofXd1 = CNDF( d1 ); NofXd2 = CNDF( d2 );
    FutureValueX = strike * ( exp( -(rate)*(time) ) );
    if (otype == 0) {                                                  // BRANCH (keep)
        OptionPrice = (sptprice * NofXd1) - (FutureValueX * NofXd2);
    } else {
        NegNofXd1 = (1.0 - NofXd1); NegNofXd2 = (1.0 - NofXd2);
        OptionPrice = (FutureValueX * NegNofXd2) - (sptprice * NegNofXd1);
    }
    return OptionPrice;
}

int numOptions;
int *otype; fptype *sptprice,*strike,*rate,*volatility,*otime,*prices;

int main(){
    FILE* f = fopen("numbers.txt","r");
    if(!f){ printf("0\n"); return 0; }
    if(fscanf(f,"%i",&numOptions)!=1){ printf("0\n"); return 0; }
    otype=(int*)malloc(numOptions*sizeof(int));
    sptprice=(fptype*)malloc(numOptions*sizeof(fptype));
    strike=(fptype*)malloc(numOptions*sizeof(fptype));
    rate=(fptype*)malloc(numOptions*sizeof(fptype));
    volatility=(fptype*)malloc(numOptions*sizeof(fptype));
    otime=(fptype*)malloc(numOptions*sizeof(fptype));
    prices=(fptype*)malloc(numOptions*sizeof(fptype));
    for(int i=0;i<numOptions;i++){
        fptype s,k,r,dq,v,t,ds,dg; char tp;
        if(fscanf(f,"%f %f %f %f %f %f %c %f %f",&s,&k,&r,&dq,&v,&t,&tp,&ds,&dg)!=9){ printf("0\n"); return 0; }
        sptprice[i]=s; strike[i]=k; rate[i]=r; volatility[i]=v; otime[i]=t;
        otype[i]=(tp=='P')?1:0;
    }
    fclose(f);
    for(int j=0;j<NUM_RUNS;j++)
        for(int i=0;i<numOptions;i++)
            prices[i]=BlkSchls(sptprice[i],strike[i],rate[i],volatility[i],otime[i],otype[i]);
    unsigned long long chk=1469598103934665603ULL;       // FNV-style hash of all price bits
    for(int i=0;i<numOptions;i++){ unsigned int u; memcpy(&u,&prices[i],4); chk=(chk^u)*1099511628211ULL; }
    printf("%llu\n",chk);
    return 0;
}
