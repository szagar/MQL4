//+------------------------------------------------------------------+
//|                                                     PipTools.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

double pips2dollars(string sym, double pips, double lots) {
   double result;
   result = pips * lots * (1 / MarketInfo(sym, MODE_POINT)) * MarketInfo(sym, MODE_TICKVALUE);
   return ( result );
}

int decimal2points_factor(string sym) {
  int factor = 10000;
  if(StringFind(sym,"JPY",0)>0) factor = 100;         // JPY pairs
  Print(__FUNCTION__,": sym=",sym,"  factor=",factor); 
  return factor;
}

double points2decimal_factor(string sym) {
Print(__FUNCTION__,": sym=",sym);
  double factor = 1.0/10000.0;
  if(StringFind(sym,"JPY",0)>0) factor = 1.0/100.0;         // JPY pairs
Print(__FUNCTION__,": factor=",factor);
  return factor;
}
