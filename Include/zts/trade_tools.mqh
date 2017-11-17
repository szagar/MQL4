//+------------------------------------------------------------------+
//|                                                  trade_tools.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Position.mqh>
#include <zts\pip_tools.mqh>
#include <zts\common.mqh>


double tradePips(Position * trade = NULL) {
  int side = 1;
  if (!trade) return 0;
  
  if (trade.OrderType == OP_SELL) side = -1;

  return (trade.ClosePrice - trade.OpenPrice) * decimal2points_factor(trade.Symbol) * PipAdj;
}

double tradePnL(Position * trade = NULL) {
  double profit = calcPnL(trade.Symbol,trade.OrderType,
                         trade.OpenPrice,trade.ClosePrice,trade.LotSize);
  return profit;
}


double calcPnL(string sym, int type, double entry, double exit, double lots) {
   double result=-999999;
   if ( type == 0 ) {
     result = (exit - entry) * lots * (1 / MarketInfo(sym, MODE_POINT)) * MarketInfo(sym, MODE_TICKVALUE);
   } else if ( type == 1 ) {
     result = (entry - exit) * lots * (1 / MarketInfo(sym, MODE_POINT)) * MarketInfo(sym, MODE_TICKVALUE);
   }
   return ( result );
}
//calcPL(activeTrade.Symbol,activeTrade.OrderType,activeTrade.OpenPrice,activeTrade.ClosePrice,activeTrade.LotSize)

string trade2str(Position *trade) {
  string str = "trade: Symbol: " + trade.Symbol + "\n" +
               "OrderEntered:" + string(trade.OrderEntered) + "\n" +
               "Opened: " + string(trade.OrderOpened) + "\n" +
               "Closed: " + string(trade.OrderClosed) + "\n" +
               "OpenPrice: " + string(trade.OpenPrice) + "\n" +
               "ClosePrice: " + string(trade.ClosePrice) + "\n" +
               "StopPrice: " + string(trade.StopPrice) + "\n" +
               "TakeProfitPrice: " + string(trade.TakeProfitPrice) + "\n" +
               "LotSize: " + string(trade.LotSize) + "\n" +
               "OrderType: " + string(trade.OrderType) + "\n" +          
               "IsPending: " + string(trade.IsPending) + "\n" +
               "Reference: " + trade.Reference + "\n";
               
  return str;
}