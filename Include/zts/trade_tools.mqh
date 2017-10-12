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


double tradePips(Position * activeTrade = NULL) {
  int side = 1;
  if (!activeTrade) return 0;
  
  if (activeTrade.OrderType == OP_SELL) side = -1;

  return (activeTrade.ClosePrice - activeTrade.OpenPrice) * decimal2points_factor(activeTrade.Symbol);
}

double tradePnL(Position * activeTrade = NULL) {
  double profit = calcPnL(activeTrade.Symbol,activeTrade.OrderType,
                         activeTrade.OpenPrice,activeTrade.ClosePrice,activeTrade.LotSize);
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