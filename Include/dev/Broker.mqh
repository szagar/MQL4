//+------------------------------------------------------------------+
//|                                                       Broker.mqh |
//|                                                       Dave Hanna |
//|                                http://nohypeforexrobotreview.com |
//+------------------------------------------------------------------+
#property copyright "Dave Hanna"
#property link      "http://nohypeforexrobotreview.com"
#property version   "1.00"
#property strict
#include <dev\Position.mqh>
#include <zts\OrderReliable.mqh>
#include <dev\common.mqh>
#include <dev\MagicNumber.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Broker
  {
private:
  MagicNumber *magic;
  
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


          string    NormalizeSymbol(string symbol) { return (StringSubstr(symbol, startingPos, 6)); }
  virtual Position *FindLastTrade();
  virtual int       GetNumberOfOrders() { return OrdersTotal(); }
  virtual Position *GetTrade(int TicketID) { SelectOrderByTicket(TicketID); return (GetPosition()); }
  virtual Position *GetPosition();
          double    GetOpenLots();
  virtual int       GetType(int ticketId);
  virtual void      GetClose(Position * trade);
  
  virtual void      SelectOrderByPosition(int position);
  virtual void      SelectOrderByTicket(int ticketId);
  
  virtual void      CreateOrder (Position * trade, string comment="");
          bool      UpdateEntryLimit(double);
          void      modifyStopLoss(int TicketID, double price);
  virtual void      SetSLandTP(Position *trade);

          bool      CancelEntryBuyLimit();
          bool      CancelEntrySellLimit();
          void      closeTrade(int ticketID);
          void      closeOpenTrades(string symbol, string strategyName);
          void      closeOpenTrades(string symbol, Enum_SIDE side, int magicN);
          void      deletePendingOrders(string symbol, string strategyName);
  virtual void      DeletePendingTrade(Position * trade);
          void      ExitLong();
          
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Broker::Broker(int symbolOffset = 0) {
  TypeName = "RealBroker";
  magic = new MagicNumber();
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

void Broker::closeTrade(int ticketID) {
  if(OrderSelect(ticketID,SELECT_BY_TICKET)) {
    if(OrderType()==0)
      bool c1 = OrderClose(ticketID,OrderLots(),Bid,UseSlippage);
    if(OrderType()==1)
      bool c2 = OrderClose(ticketID,OrderLots(),Ask,UseSlippage);
    if(GetLastError()==136) Debug4(__FUNCTION__,__LINE__,"GetLastError=136");
    //if(GetLastError()==136) continue;
  }
}

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

void Broker::closeOpenTrades(string symbol, string strategyName) {
  for(int x=0;x<OrdersTotal();x++) {
    if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)) {
      if(StringCompare(magic.getStrategy(OrderMagicNumber()),strategyName,false)==0) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderType()==0 || OrderType()==1)
        closeTrade(OrderTicket());
    }    
  }
}

void Broker::closeOpenTrades(string symbol, Enum_SIDE side, int magicN=0) {
  for(int x=0;x<OrdersTotal();x++) {
    if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)) {
      if(OrderMagicNumber()!=magicN) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(side == Long && OrderType()==OP_BUY)    //0)
        closeTrade(OrderTicket());
      if(side == Short && OrderType()==OP_SELL)    //1)
        closeTrade(OrderTicket());
    }    
  }
}

void Broker::modifyStopLoss(int TicketID, double price) {
  if(!OrderSelect(TicketID,SELECT_BY_TICKET)) {
    Warn(__FUNCTION__+": could not select ticket");
    return;
  }
  Debug(__FUNCTION__,__LINE__,"OrderModify("+string(OrderTicket())+", "+DoubleToStr(OrderOpenPrice(),Digits)+", "+DoubleToStr(NormalizeDouble(price,Digits),Digits)+", "+DoubleToStr(OrderTakeProfit(),Digits)+", 0, Pink))");
  if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(price,Digits),
                  OrderTakeProfit(), 0, Pink))
    Warn(OrderSymbol() +" (OrderModify Error) "+ ErrorDescription(GetLastError()));
}
  
void Broker::SelectOrderByPosition(int position) {
  if(!OrderSelect(position, SELECT_BY_POS))
    Warn(__FUNCTION__+": OrderSelect NOT successful!");                        
}

void Broker::SelectOrderByTicket(int ticketId) {
  if(!OrderSelect(ticketId, SELECT_BY_TICKET))
    Warn(__FUNCTION__+": OrderSelect NOT successful!");                    
}

Position *Broker::GetPosition() {
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
  newTrade.SideX = (newTrade.LotSize > 0 ? 1 : -1);
  newTrade.Magic = OrderMagicNumber();
  newTrade.Expiration = OrderExpiration();
  return newTrade;
}

double Broker::GetOpenLots() {
  double size = 0;
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if ( OrderSelect(i, SELECT_BY_POS) )
      if(OrderSymbol() == Symbol())
        size += OrderLots();
  }
  return(size);
}

void Broker::ExitLong() {
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if ( OrderSelect(i, SELECT_BY_POS) )
      if(OrderSymbol() == Symbol())
        Print(__FUNCTION__,": WRITE CODE --- exit long here");
  }
}

int Broker::GetType(int ticketId) {
  SelectOrderByTicket(ticketId);
  return OrderType();
}

void Broker::GetClose(Position * trade) {
  SelectOrderByTicket(trade.TicketId);
  trade.ClosePrice = OrderClosePrice();
  trade.OrderClosed = OrderCloseTime();
}


void Broker::SetSLandTP(Position *trade) {
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

void Broker::CreateOrder (Position * trade, string comment="") {
  Info2(__FUNCTION__,__LINE__,"Entered");
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
                    trade.Magic,   // magic
                    trade.Expiration,
                    trade.ArrowColor);
}

void Broker::DeletePendingTrade ( Position * trade) {
  if(trade.OrderType < 2) {     // then not a pending order
    Alert("Attempt to delete an open trade. Close order instead of Deleting it.");
    return;
  }
  if(OrderDelete(trade.TicketId))
    Warn("Order #" + string(trade.TicketId) + " deleted.");
  else
    Warn("Order #" + string(trade.TicketId) + " NOT deleted.");
}

void Broker::deletePendingOrders(string symbol, string strategyName) {
  Info2(__FUNCTION__,__LINE__,"Entered");
  bool deleted;
  pendingOrders = false;
  if (OrdersTotal()==0) return;
  for (int i=OrdersTotal()-1; i>=0; i--) {
    Info2(__FUNCTION__,__LINE__,OrderSymbol()+" "+string(OrderType()));
    if(StringCompare(magic.getStrategy(OrderMagicNumber()),strategyName,false)==0) continue;
    if(OrderSymbol()!=Symbol()) continue;
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) {
      Info2(__FUNCTION__,__LINE__,"in: "+OrderSymbol()+" "+string(OrderType()));
      if (OrderType()==4) {
        deleted=OrderDelete(OrderTicket());
        if (deleted==false) Info("Error: " + string(GetLastError()));
        if (deleted==true) Info("Order " + string(OrderTicket()) + " Deleted.");
      }
      if (OrderType()==5) {
        deleted=OrderDelete(OrderTicket());
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) Print ("Order ", OrderTicket() ," Deleted.");
      }
    }
  }
}

Position *Broker::FindLastTrade() {
  for(int ix=OrdersHistoryTotal()-1;ix>=0;ix--) {
    if(OrderSelect(ix, SELECT_BY_POS, MODE_HISTORY) != true) return(NULL); 
    if(OrderSymbol() == Symbol()) return GetPosition();
  }
  return NULL;
}
