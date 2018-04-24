//+------------------------------------------------------------------+
//|                                                       common.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


#ifndef COMMONCONSTANTS
#define COMMONCONSTANTS

double PipSize;
int PipFact;
double P2D, D2P;

void setSomeConstants() {
  PipSize = MarketInfo(Symbol(),MODE_TICKSIZE);
  if(PipSize == 0.00001 || PipSize == 0.001)
    PipSize *= 10;
  PipFact = int(1/PipSize);

  D2P = (StringFind(Symbol(),"JPY",0)>0 ? 100 : 10000);
  P2D = 1.0/D2P;
}

int GetSlippage() {
  if(Digits() == 2 || Digits() == 4)
    return(Slippage);
  else if(Digits() == 3 || Digits() ==5)
    return(Slippage*10);
  return(Digits());
}
int UseSlippage = GetSlippage();

#endif

