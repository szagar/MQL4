//+------------------------------------------------------------------+
//|                                           ClosePendingOrders.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

int ClosePendintOrders(string symbol="",int only_magic=0,int skip_magic=0) {
  bool deleted;
  int cnt=0;
  bool limit_buy=true;
  bool stop_buy=true;
  bool limit_sell=true;
  bool stop_sell=true;

  if (OrdersTotal()==0) return(0);
  for (int i=OrdersTotal()-1; i>=0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) {
      //Print ("order ticket: ", OrderTicket(), "order magic: ", OrderMagicNumber(), " Order Symbol: ", OrderSymbol());
      if (only_magic>0 && OrderMagicNumber()!=only_magic) continue;
      if (skip_magic>0 && OrderMagicNumber()==skip_magic) continue;
      if (symbol!="" && OrderSymbol()!=symbol) {
        //Print("order symbol different");
        continue;
      }
      if (OrderType()==2 && limit_buy==true) {
        //Print ("Error: ",  GetLastError());
        deleted=OrderDelete(OrderTicket());
        //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_BID));
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) {
          Print ("Order ", OrderTicket() ," Deleted.");
          cnt++;
        }
      }
      if (OrderType()==4 && stop_buy==true) {
        //Print ("Error: ",  GetLastError());
        deleted=OrderDelete(OrderTicket());
        //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_ASK));
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) {
          Print ("Order ", OrderTicket() ," Deleted.");
          cnt++;
        }
      }
      if (OrderType()==3 && limit_sell==true) {
        //Print ("Error: ",  GetLastError());
        deleted=OrderDelete(OrderTicket());
        //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_BID));
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) {
          Print ("Order ", OrderTicket() ," Deleted.");
          cnt++;
        }
      }
      if (OrderType()==5 && stop_sell==true) {
        //Print ("Error: ",  GetLastError());
        deleted=OrderDelete(OrderTicket());
        //Print ("Error: ",  GetLastError(), " price: ", MarketInfo(OrderSymbol(),MODE_ASK));
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) {
          Print ("Order ", OrderTicket() ," Deleted.");
          cnt++;
        }
      }
    }
  }
  return(cnt);
}
