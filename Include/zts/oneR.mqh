//+------------------------------------------------------------------+
//|                                                         oneR.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

int LookupStopPips(string symbol) {
  string ConfigureStops = "===Configure Stop Loss Levels===";
  int DefaultStopPips = 12;
  string ExceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
  
  int stop = DefaultStopPips;
  int pairPosition = StringFind(ExceptionPairs, symbol, 0);
  if (pairPosition >=0) {
     int slashPosition = StringFind(ExceptionPairs, "/", pairPosition) + 1;
     stop = StringToInteger(StringSubstr(ExceptionPairs,slashPosition));
  }
  return stop;
}