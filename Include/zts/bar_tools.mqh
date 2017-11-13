//+------------------------------------------------------------------+
//|                                                    bar_tools.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

bool CheckNewBar() {
  static datetime time0;
  if(Time[0] == time0) return false;
  time0 = Time[0];
  return true;  
}