//+------------------------------------------------------------------+
//|                                                  order_tools.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <zts\common.mqh>

void ModifyStopLoss(double _stopLoss) {
  if( OrderModify(OrderTicket(),OrderOpenPrice(),_stopLoss,OrderTakeProfit(),0,CLR_NONE) ) {
    PlaySound("OrderModifySuccess");
  } else {
    Warn(__FUNCTION__+": ModifyStopLoss failed, ");
    PlaySound("OrderModifyFailed");
  }
}

void ClosePendingLimitOrders(string symbol="all") {
  int otype;
  bool result;
  
  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--) {
    if(!OrderSelect(i, SELECT_BY_POS)) Zalert(__FUNCTION__+": could not select order");
    if(symbol != "all" && OrderSymbol() != symbol) continue;
    
    otype = OrderType();

    result = false;
    switch(otype) {
      case OP_BUYLIMIT:
      case OP_SELLLIMIT:
        result = OrderDelete( OrderTicket());
        break;
    }
    
    if(result == false) Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
  }
}