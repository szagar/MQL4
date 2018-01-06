//+------------------------------------------------------------------+
//|                                                      BigBars.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <zts\bar_tools.mqh>
#include <zts\common.mqh>

int barNumber = 0;
int tickNumber = 0;
datetime endOfDay;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  tickNumber++;
  if(CheckNewBar()) {
    barNumber++;

    if(Time[0] >= endOfDay) {
      endOfDay += 24*60*60;
      //StatsEndOfDay(FnEodStats);
      CleanupEndOfDay();
      beginningOfDay += 24*60*60;
    }
  }
  PopulateActiveTradeIds();
  PopulateDeletedTrades();
   
  //This will populate the new trade array, add new trade to ActiveTrades, and check for replaced Delete trades
  PopulateNewTrades();   
  CheckForClosedTrades();
  CheckForPendingTradesGoneActive();
  CheckForNewTrades();   
}