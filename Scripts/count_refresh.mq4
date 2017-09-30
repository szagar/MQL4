//+------------------------------------------------------------------+
//|                                                count_refresh.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
    int i, Count;
    for (i=1' i<=5; i++)
      {
        Count = 0;
        while(RefreshRates() == false)
          {
            Count = Count + 1;
          }
        Alert("Tick ",i,", loops ", Count);
      }
    return
//---
   
  }
//+------------------------------------------------------------------+
