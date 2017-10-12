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
  if(StringFind(OrderSymbol(),"JPY",0)>0) factor = 100;         // JPY pairs
  return factor;
}