//+------------------------------------------------------------------+
//|                                                    dailyPips.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      ""
//#property strict

#include <zts\orderselect_info.mqh>
#include <zts\trade_tools.mqh>

double dailyPnL_live() {
  return RealizedProfitToday() + UnRealizedProfitToday();
}

double dailyPnL_worstCase() {
  double openAndLocked = LockedInProfit();
  //Alert("oprealizedenAndLocked="+openAndLocked);
  
  double realized = RealizedProfitToday();
  //Alert("realized="+realized);
  
  //Alert("Total Point for Today: " + (openAndLocked+realized));
  
  return openAndLocked + realized;
}


double LockedInProfit() {
  double profit=0;
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderType()==OP_BUY || OrderType()==OP_SELL) {
      if(TimeDayOfYear(OrderOpenTime())==TimeDayOfYear(TimeCurrent()) ) {
        int Dec2pt = 10000;
        if(StringFind(OrderSymbol(),"JPY",0)>0) Dec2pt = 100;         // JPY pairs
        profit += calcPnL(OrderSymbol(), OrderType(), OrderOpenPrice(), OrderStopLoss(), OrderLots());
        //if(OrderType()==OP_BUY){
        //  _buyspips+=(OrderStopLoss()-OrderOpenPrice())*Dec2pt;
        //  profit += calcPnL(OrderSymbol, OrderType, OrderOpenPrice, OrderStopLoss, OrderLots)
        //}
        //if(OrderType()==OP_SELL){
        //  _sellspips+=(OrderOpenPrice()-OrderStopLoss())*Dec2pt;
        //}
      }
    }
  }
  return profit;
}

double UnRealizedProfitToday() {
  double profit = 0;
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderType()==OP_BUY || OrderType()==OP_SELL) {
      if(TimeDayOfYear(OrderOpenTime())==TimeDayOfYear(TimeCurrent()) ) {
        profit += calcPnL(OrderSymbol(), OrderType(), OrderOpenPrice(), OrderClosePrice(), OrderLots());
      }
    }
  }
  return profit;
}

double RealizedProfitToday() {
  double profit = 0;
  for(int i=OrdersHistoryTotal()-1; i>=0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
    if(OrderType()==OP_BUY || OrderType()==OP_SELL) {
      if(TimeDayOfYear(OrderOpenTime())==TimeDayOfYear(TimeCurrent()) ) {
        profit += calcPnL(OrderSymbol(), OrderType(), OrderOpenPrice(), OrderClosePrice(), OrderLots());
      }
    }
  }
  return profit;
}      

