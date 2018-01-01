//+------------------------------------------------------------------+
//|                                                    dailyPips.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      ""
//#property strict

#include <zts\orderselect_info.mqh>
//#include <zts\pip_tools.mqh>

double dailyPips_live() {
  return RealizedPipsToday() + UnRealizedPipsToday();
}

double dailyPips_worstCase() {
  double openAndLocked = LockedInPips();
  //Alert("oprealizedenAndLocked="+openAndLocked);
  
  double realized = RealizedPipsToday();
  //Alert("realized="+realized);
  
  //Alert("Total Point for Today: " + (openAndLocked+realized));
  
  return openAndLocked + realized;
}

double LockedInPips() {
  double _buyspips=0, _sellspips=0;
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderType()==OP_BUY || OrderType()==OP_SELL) {
      //Alert("Info:  " + OrderSelectInfo());
      if(TimeDayOfYear(OrderOpenTime())==TimeDayOfYear(TimeCurrent()) ) {
        int Dec2pt = 10000;
        //if(Digits==3) Dec2pt = 100;         // JPY pairs
        if(StringFind(OrderSymbol(),"JPY",0)>0) Dec2pt = 100;         // JPY pairs
        //Alert("Symbol="+OrderSymbol()+"  Dec2pt="+Dec2pt);
        if(OrderType()==OP_BUY){
          //_buyspips+=(OrderClosePrice()-OrderOpenPrice())*Dec2pt;
          _buyspips+=(OrderStopLoss()-OrderOpenPrice())*Dec2pt;
          //Alert(_buyspips+"+=("+OrderStopLoss()+"-"+OrderOpenPrice()+")*"+Dec2pt);
        }
        if(OrderType()==OP_SELL){
          //_sellspips+=(OrderOpenPrice()-OrderClosePrice())*Dec2pt;
          _sellspips+=(OrderOpenPrice()-OrderStopLoss())*Dec2pt;
          //Alert(_sellspips+"+=("+OrderOpenPrice()+"-"+OrderStopLoss()+")*"+Dec2pt);
        }
      }
    }
  }
  return(_buyspips + _sellspips);
}

double UnRealizedPipsToday() {
  double _buyspips=0, _sellspips=0;
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderType()==OP_BUY || OrderType()==OP_SELL) {
      if(TimeDayOfYear(OrderOpenTime())==TimeDayOfYear(TimeCurrent()) ) {
        int Dec2pt = 10000;
        if(StringFind(OrderSymbol(),"JPY",0)>0) Dec2pt = 100;         // JPY pairs
        if(OrderType()==OP_BUY){
          _buyspips+=(OrderClosePrice()-OrderOpenPrice())*Dec2pt;
        }
        if(OrderType()==OP_SELL){
          _sellspips+=(OrderOpenPrice()-OrderClosePrice())*Dec2pt;
        }
      }
    }
  }
  return _buyspips + _sellspips;
}

double RealizedPipsToday() {
  double _buyspips=0, _sellspips=0;
  for(int i=OrdersHistoryTotal()-1; i>=0; i--) {
    if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
    if(OrderType()==OP_BUY || OrderType()==OP_SELL) {
      //Alert("Info:  " + OrderSelectInfo());
      if(TimeDayOfYear(OrderOpenTime())==TimeDayOfYear(TimeCurrent()) ) {
        int Dec2pt = 10000;
        if(StringFind(OrderSymbol(),"JPY",0)>0) Dec2pt = 100;         // JPY pairs
        //Alert("Symbol="+OrderSymbol()+"  Dec2pt="+Dec2pt);
        if(OrderType()==OP_BUY){
          //_buyspips+=(OrderClosePrice()-OrderOpenPrice())*Dec2pt;
          _buyspips+=(OrderClosePrice()-OrderOpenPrice())*Dec2pt;
          //Alert(_buyspips+"+=("+OrderStopLoss()+"-"+OrderOpenPrice()+")*"+Dec2pt);
        }
        if(OrderType()==OP_SELL){
          //_sellspips+=(OrderOpenPrice()-OrderClosePrice())*Dec2pt;
          _sellspips+=(OrderOpenPrice()-OrderClosePrice())*Dec2pt;
          //Alert(_sellspips+"+=("+OrderOpenPrice()+"-"+OrderStopLoss()+")*"+Dec2pt);
        }
      }
    }
  }
  return _buyspips + _sellspips;
}      

