//+------------------------------------------------------------------+
//|                                                       common.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


double TickSize, PipSize;
int PipFact;
double P2D, D2P;

void setSomeConstants() {
  TickSize = MarketInfo(Symbol(),MODE_TICKSIZE);
  PipSize = TickSize;
  if(TickSize == 0.00001 || TickSize == 0.001)
    PipSize *= 10;
  PipFact = int(1/PipSize);

  D2P = (StringFind(Symbol(),"JPY",0)>0 ? 100 : 10000);
  P2D = 1.0/D2P;

  //Info2(__FUNCTION__,__LINE__,"TickSize = "+string(TickSize));
  //Info2(__FUNCTION__,__LINE__,"PipSize  = "+string(PipSize));
  //Info2(__FUNCTION__,__LINE__,"PipFact  = "+string(PipFact));
}


double CommonSetPoint() {
  return((Digits==5||Digits==3)?Point*10:Point);
}

double CommonSetPipAdj() {
  return(0.1);
}
double pips2dollars(string sym, double pips, double lots) {
   double result;
   result = pips * lots * (1 / MarketInfo(sym, MODE_POINT)) * MarketInfo(sym, MODE_TICKVALUE);
   return ( result );
}

int decimal2pips(string sym) {
  int factor = 10000;
  Debug(__FUNCTION__,__LINE__,": sym="+sym+"  factor="+string(factor)); 
  return factor;
}

double points2decimal_factor(string sym) {
  double factor = 1.0/10000.0;
  if(StringFind(sym,"JPY",0)>0) factor = 1.0/100.0;         // JPY pairs
  Debug(__FUNCTION__,__LINE__," "+sym+": factor="+string(factor));
  return factor;
}

//extern int Slippage=5;
int Slippage=5;
int GetSlippage() {
  if(Digits() == 2 || Digits() == 4)
    return(Slippage);
  else if(Digits() == 3 || Digits() ==5)
    return(Slippage*10);
  return(Digits());
}

#ifndef ZCOMMON
#define ZCOMMON

double OnePoint = CommonSetPoint();
double PipAdj = CommonSetPipAdj();
int UseSlippage = GetSlippage();

double BaseCcyTickValue = MarketInfo(Symbol(),MODE_TICKVALUE); // Tick value in the deposit currency
// Point - The current symbol point value in the quote currency
// MODE_POINT - Point size in the quote currency. For the current symbol, it is stored in the predefined variable Point

#endif

