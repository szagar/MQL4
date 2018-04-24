//+------------------------------------------------------------------+
//|                                BigPippenSmaCrossoverPullback.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
// Indicators:
//    100 SMA
//    200 SMA
//    Stochastic(14,3,3)
// Entry:
//    - Buy 1st isntance stoch crosses up thru 25 after upward SMA crossover
//    - Sell 1st insance sock drops from 75 after downward SMA crossover
// Exit:
//    - 150pip stop loss
//    - 300pip TP
//    - move stop to BE when 150 pip profit
// Ideas:
//    - start trailing stop at 150 pip profit

#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
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
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
