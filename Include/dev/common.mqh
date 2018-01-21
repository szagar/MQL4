//+------------------------------------------------------------------+
//|                                                       common.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <dev/enum_types.mqh>

int GetSlippage() {
  if(Digits() == 2 || Digits() == 4)
    return(Slippage);
  else if(Digits() == 3 || Digits() ==5)
    return(Slippage*10);
  return(Digits());
}

double CommonSetPoint() {
  return((Digits==5||Digits==3)?Point*10:Point);
}

double CommonSetPipAdj() {
  //if(Digits==5||Digits==3) return(10);
  //return(1);
  return(0.1);
}
double pips2dollars(string sym, double pips, double lots) {
   double result;
   result = pips * lots * (1 / MarketInfo(sym, MODE_POINT)) * MarketInfo(sym, MODE_TICKVALUE);
   return ( result );
}

int decimal2points_factor(string sym) {
  int factor = 10000;
  if(StringFind(sym,"JPY",0)>0) factor = 100;         // JPY pairs
  Debug(__FUNCTION__,__LINE__,": sym="+sym+"  factor="+string(factor)); 
  return factor;
}

double points2decimal_factor(string sym) {
  double factor = 1.0/10000.0;
  if(StringFind(sym,"JPY",0)>0) factor = 1.0/100.0;         // JPY pairs
  Debug(__FUNCTION__,__LINE__," "+sym+": factor="+string(factor));
  return factor;
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

