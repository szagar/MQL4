//+------------------------------------------------------------------+
//|                                                       Broker.mqh |
//|                                                       Dave Hanna |
//|                                http://nohypeforexrobotreview.com |
//+------------------------------------------------------------------+
#property copyright "Dave Hanna"
#property link      "http://nohypeforexrobotreview.com"
#property version   "1.00"
#property strict
#include <zts\Position.mqh>
#include <zts\OrderReliable.mqh>
#include <zts\common.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Broker
  {
private:
  int startingPos;
  string symbolPrefix;
  string symbolSuffix;
  color cancelColor;

  bool GetPendingLimitBuyOrder();
  bool GetPendingLimitOrder(int);
  bool CancelEntryLimit(int);
  
  bool GetPendingBuyOrderLimitPrice();
  bool GetPendingSellOrderLimitPrice();
  bool GetPendingOrderLimitPrice(int);


public:
  Broker(int symbolOffset = 0);
  ~Broker();
  string TypeName;

  bool UpdateEntryLimit(double);
  bool CancelEntryBuyLimit();
  bool CancelEntrySellLimit();

  virtual int GetNumberOfOrders() {
    return OrdersTotal();
  }
  virtual Position *GetTrade(int TicketID) {
    SelectOrderByTicket(TicketID);
    return (GetPosition());
  }

  void modifyStopLoss(int TicketID, double price) {
    if(!OrderSelect(TicketID,SELECT_BY_TICKET)) {
      Warn(__FUNCTION__+": could not select ticket");
      return;
    }
    if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(price,Digits), OrderTakeProfit(), 0, Pink))
                    Warn(OrderSymbol() +" (OrderModify Error) "+ ErrorDescription(GetLastError()));
  }
  

  virtual void SelectOrderByPosition(int position) {
    if(!OrderSelect(position, SELECT_BY_POS))
      Warn(__FUNCTION__+": OrderSelect NOT successful!");                        
  }

  virtual void SelectOrderByTicket(int ticketId) {
    if(!OrderSelect(ticketId, SELECT_BY_TICKET))
      Warn(__FUNCTION__+": OrderSelect NOT successful!");                    
  }

  virtual Position *GetPosition() {
    Position * newTrade = new Position();
    newTrade.TicketId = OrderTicket();  
    newTrade.OrderType = OrderType();
    newTrade.IsPending = newTrade.OrderType != OP_BUY && newTrade.OrderType != OP_SELL;
    newTrade.Symbol = NormalizeSymbol(OrderSymbol());
    newTrade.OrderOpened = OrderOpenTime();
    newTrade.OpenPrice = OrderOpenPrice();
    newTrade.ClosePrice = OrderClosePrice();
    newTrade.OrderClosed = OrderCloseTime();
    newTrade.StopPrice = OrderStopLoss();
    newTrade.TakeProfitPrice = OrderTakeProfit();
    newTrade.LotSize = OrderLots();
    newTrade.Side = (newTrade.LotSize > 0 ? Long : Short);
    newTrade.Magic = OrderMagicNumber();
    return newTrade;
  }

  double GetOpenLots() {
    double size = 0;
    for(int i=OrdersTotal()-1; i>=0; i--) {
      if ( OrderSelect(i, SELECT_BY_POS) )
        if(OrderSymbol() == Symbol())
          size += OrderLots();
    }
    return(size);
  }
  
  void ExitLong() {
    for(int i=OrdersTotal()-1; i>=0; i--) {
      if ( OrderSelect(i, SELECT_BY_POS) )
        if(OrderSymbol() == Symbol())
          Print(__FUNCTION__,": WRITE CODE --- exit long here");
    }
  }
  
  virtual int GetType(int ticketId) {
    SelectOrderByTicket(ticketId);
    return OrderType();
  }

  virtual void GetClose(Position * trade) {
    SelectOrderByTicket(trade.TicketId);
    trade.ClosePrice = OrderClosePrice();
    trade.OrderClosed = OrderCloseTime();
  }

  virtual void SetSLandTP(Position *trade) {
    SelectOrderByTicket(trade.TicketId);
    if((trade.StopPrice == OrderStopLoss()) &&
        trade.TakeProfitPrice == OrderTakeProfit()) {
      Print(trade.Symbol + ": Not sending order to broker because SL and TP already set");
      return;
    }
    if (!OrderModifyReliable(trade.TicketId,
                             trade.OpenPrice,
                             trade.StopPrice,
                             trade.TakeProfitPrice,0 )) {
      Alert("Setting SL and TP for " + trade.Symbol + " failed.");
    }
  }

  virtual void CreateOrder (Position * trade, string comment="") {
    Debug4(__FUNCTION__,__LINE__,"Entered");
    if (trade.LotSize == 0.0) {
      Warn("Trade with zero lot size cannot be entered.");
      return;
    }
    OrderSendReliable(symbolPrefix + trade.Symbol + symbolSuffix, 
                      trade.OrderType,
                      trade.LotSize,
                      trade.OpenPrice,
                      0,    //slippage
                      trade.StopPrice,  //stop loss
                      trade.TakeProfitPrice,  //take profit
                      trade.Reference,   //smz comment
                      trade.Magic);   // magic
  }

  virtual void DeletePendingTrade ( Position * trade) {
    if(trade.OrderType < 2) {     // then not a pending order
      Alert("Attempt to delete an open trade. Close order instead of Deleting it.");
      return;
    }
    if(OrderDelete(trade.TicketId))
      Warn("Order #" + string(trade.TicketId) + " deleted.");
    else
      Warn("Order #" + string(trade.TicketId) + " NOT deleted.");
  }

  virtual Position * FindLastTrade() {
    for(int ix=OrdersHistoryTotal()-1;ix>=0;ix--) {
      if(OrderSelect(ix, SELECT_BY_POS, MODE_HISTORY) != true) return(NULL); 
      if(OrderSymbol() == Symbol()) return GetPosition();
    }
    return NULL;
  }
  
  string NormalizeSymbol(string symbol) {
    return (StringSubstr(symbol, startingPos, 6));
  }

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Broker::Broker(int symbolOffset = 0) {
  TypeName = "RealBroker";
  cancelColor = clrPeru;
  startingPos = symbolOffset;
  string symbol = Symbol();
  if(symbolOffset == 0)
    symbolPrefix = "";
  else
    symbolPrefix = StringSubstr(symbol, 0, symbolOffset);
  symbolSuffix = StringSubstr(symbol,6+symbolOffset);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Broker::~Broker() {
}
//+------------------------------------------------------------------+

bool Broker::GetPendingBuyOrderLimitPrice() {
  bool ret = GetPendingOrderLimitPrice(OP_BUYLIMIT);
  return(ret);
}

bool Broker::GetPendingSellOrderLimitPrice() {
  bool ret = GetPendingOrderLimitPrice(OP_SELLLIMIT);
  return(ret);
}
bool Broker::GetPendingOrderLimitPrice(int side=OP_BUYLIMIT||OP_SELLLIMIT) {
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if ( OrderSelect(i, SELECT_BY_POS) )
      if(OrderSymbol() == Symbol())
        if(OrderType() && side)
          return(OrderOpenPrice());
  }
  return(0);
}

bool Broker::GetPendingLimitOrder(int side=OP_BUYLIMIT||OP_SELLLIMIT) {
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if ( OrderSelect(i, SELECT_BY_POS) )
      if(OrderSymbol() == Symbol())
        if(OrderType() && side)
          return(OrderTicket());
  }
  return(0);
}

bool Broker::CancelEntryBuyLimit() {
  bool ret = CancelEntryLimit(OP_BUYLIMIT);
  return(ret);
}

bool Broker::CancelEntrySellLimit() {
  bool ret = CancelEntryLimit(OP_SELLLIMIT);
  return(ret);
}

bool Broker::CancelEntryLimit(int side=OP_BUYLIMIT||OP_SELLLIMIT) {
  int tradeId = GetPendingLimitOrder(side);
  if(tradeId > 0) {
    bool ret=OrderDelete(tradeId,cancelColor);
    return(true);
  }
  return(false);
}

/**
bool Broker::UpdateEntryBuyLimit(double _px) {
  int tradeId = GetPendingBuyLimitBuyOrder();
  if(tradeId > 0) {
    bool ret=OrderModify(tradeId,_px);
    reutrn(true);
  }
  Warn(__FUNCTION__+": Could not update limit order for entry");
  return(false);
}
**/
