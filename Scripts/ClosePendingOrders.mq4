//+------------------------------------------------------------------+
//|                                           ClosePendingOrders.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

extern bool limit_buy=true;
extern bool stop_buy=true;
extern bool limit_sell=true;
extern bool stop_sell=true;
extern int only_magic=0;
extern int skip_magic=0;
extern bool only_below_symbol=false;
extern string symbol="EURUSD";


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  bool deleted;
  if (OrdersTotal()==0) return;
  for (int i=OrdersTotal()-1; i>=0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) {
      //Print ("order ticket: ", OrderTicket(), "order magic: ", OrderMagicNumber(), " Order Symbol: ", OrderSymbol());
      if (only_magic>0 && OrderMagicNumber()!=only_magic) continue;
      if (skip_magic>0 && OrderMagicNumber()==skip_magic) continue;
      if (only_below_symbol==true && OrderSymbol()!=symbol) {
        Print("order symbol different");
        continue;
      }
      if (OrderType()==2 && limit_buy==true) {
        //Print ("Error: ",  GetLastError());
        deleted=OrderDelete(OrderTicket());
        //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_BID));
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) Print ("Order ", OrderTicket() ," Deleted.");
      }
      if (OrderType()==4 && stop_buy==true) {
        //Print ("Error: ",  GetLastError());
        deleted=OrderDelete(OrderTicket());
        //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_ASK));
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) Print ("Order ", OrderTicket() ," Deleted.");
      }
      if (OrderType()==3 && limit_sell==true) {
        //Print ("Error: ",  GetLastError());
        deleted=OrderDelete(OrderTicket());
        //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_BID));
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) Print ("Order ", OrderTicket() ," Deleted.");

      }
      if (OrderType()==5 && stop_sell==true) {
        //Print ("Error: ",  GetLastError());
        deleted=OrderDelete(OrderTicket());
        //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_ASK));
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) Print ("Order ", OrderTicket() ," Deleted.");

      }
    }
  }
  //return(0);
}
