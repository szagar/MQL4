//+------------------------------------------------------------------+
//|                                             Check_Daily_Pips.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//input Enum_Pairs Symbol=EURUSD(EU)
//#include <zts\enums\enum_time.mqh>
 
//input Enum_Hour StartHour=h07;      //Start opearation hour
//input Enum_Hour LastHour=h17;       //Last operation hour






#include <zts\daily_pips.mqh>;
#include <zts\daily_pnl.mqh>;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
  //float pips = dailyPips_worstCase();
  string str = "daily pips = " + DoubleToString(dailyPips_worstCase(),2) + "   dailyPips_live="+dailyPips_live() + "    UnRealPips = " + DoubleToStr(UnRealizedPipsToday(),2) +
        "    day pnl = " + DoubleToStr(dailyPnL_live(),2) + "   unrealized pnl = " + DoubleToString(UnRealizedProfitToday(),2);
  Print(str);
  Comment(str);
  if (dailyPips_live() < -50.0) {
    int cnt = CloseAllPendingOrders();
    if (cnt>0) Alert("Closed "+ string(cnt) + " pending orders");
  }
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


//extern string  Visit="www.think-trust-trade.com";
//extern string  Like="www.facebook.com/ThinkTrustTrade";
extern bool limit_buy=true;
extern bool stop_buy=true;
extern bool limit_sell=true;
extern bool stop_sell=true;
extern int only_magic=0;
extern int skip_magic=0;
extern bool only_below_symbol=false;
extern string symbol="EURUSD";

int CloseAllPendingOrders() {
  bool deleted;
  int cnt_pass=0, cnt_fail=0;
  if (OrdersTotal()==0) return(0);
  for (int i=OrdersTotal()-1; i>=0; i--) {
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) {
            //Print ("order ticket: ", OrderTicket(), "order magic: ", OrderMagicNumber(), " Order Symbol: ", OrderSymbol());
            if (only_magic>0 && OrderMagicNumber()!=only_magic) continue;
            if (skip_magic>0 && OrderMagicNumber()==skip_magic) continue;
            if (only_below_symbol==true && OrderSymbol()!=symbol) 
            {Print("order symbol different"); continue;}
            if (OrderType()==2 && limit_buy==true) {// long
               //Print ("Error: ",  GetLastError());
               deleted=OrderDelete(OrderTicket());
               //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_BID));
               if (deleted==false) Print ("Error: ",  GetLastError());
               if (deleted==true) {
                 cnt_pass++;
                 Print ("Order ", OrderTicket() ," Deleted.");
               }
            }
            if (OrderType()==4 && stop_buy==true) {   // short
               //Print ("Error: ",  GetLastError());
               deleted=OrderDelete(OrderTicket());
               //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_ASK));
               if (deleted==false) Print ("Error: ",  GetLastError());
               if (deleted==true) {
                 Print ("Order ", OrderTicket() ," Deleted.");
                 cnt_pass++;
               }
               
            }   
            if (OrderType()==3 && limit_sell==true) {   // long
               //Print ("Error: ",  GetLastError());
               deleted=OrderDelete(OrderTicket());
               //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_BID));
               if (deleted==false) Print ("Error: ",  GetLastError());
               if (deleted==true) {
                 Print ("Order ", OrderTicket() ," Deleted.");
                 cnt_pass++;
               }
            }
            if (OrderType()==5 && stop_sell==true) {  // short
               //Print ("Error: ",  GetLastError());
               deleted=OrderDelete(OrderTicket());
               //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_ASK));
               if (deleted==false) Print ("Error: ",  GetLastError());
               if (deleted==true) {
                 Print ("Order ", OrderTicket() ," Deleted.");
                 cnt_pass++;
               }
            }   
          }
      }
  
   return(cnt_pass);
  }