//+------------------------------------------------------------------+
//|                                                     Position.mqh |
//|                                                       Dave Hanna |
//|                                http://nohypeforexrobotreview.com |
//+------------------------------------------------------------------+
#property copyright "Dave Hanna"
#property link      "http://nohypeforexrobotreview.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Position {
private:
  string orderTypeStr[7];
  string orderType_toHuman(int);

  void initOrderTypeLookup();
public:
  Position();
  ~Position();
  
  string toHuman();
  string inspect();

  int TicketId;
  string Symbol;
  Enum_SIDE Side;
  int SideX;
  int OneRpips;
  int RewardPips;
  datetime OrderEntered;
  datetime OrderOpened;
  datetime OrderClosed;
  double OpenPrice;
  double ClosePrice;
  double StopPrice;
  double TakeProfitPrice;
  double LotSize;
  int OrderType;                    
  //Enum_OP_ORDER_TYPES OrderType;                    
  bool IsPending;
  string Reference;    //smz
  int Magic;
  datetime Expiration;
  color ArrowColor;
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Position::Position() {
  initOrderTypeLookup();

}

Position::~Position() {
}


//Robo::tradeLong: T R A D E Long:  0: EURUSD(0) Type: OP_BUYSTOP Size: 0.10 @1.17362 SL: 1.17343 PT: 0.00000
string Position::toHuman() {
  string str = string(TicketId)+": "+Symbol;
  str += EnumToString(Side);
  str += "("+IntegerToString(OneRpips)+"/"+IntegerToString(RewardPips)+")";
  str += " Type: "+orderType_toHuman(OrderType);
  str += " Size: "+DoubleToStr(LotSize,2);
  str += " @"+DoubleToStr(OpenPrice,Digits);
  str += " SL: "+DoubleToStr(StopPrice,Digits);
  str += " PT: "+DoubleToStr(TakeProfitPrice,Digits);
  return(str);
}

string Position::orderType_toHuman(int ot) {
  return(orderTypeStr[ot]);
}

void Position::initOrderTypeLookup() {
  orderTypeStr[0] = "DNK";
  orderTypeStr[1] = "OP_BUY";       //  - buy order,
  orderTypeStr[2] = "OP_SELL";      //  - sell order,
  orderTypeStr[3] = "OP_BUYLIMIT";  //  - buy limit pending order,
  orderTypeStr[4] = "OP_BUYSTOP";   //  - buy stop pending order,
  orderTypeStr[5] = "OP_SELLLIMIT"; //  - sell limit pending order,
  orderTypeStr[6] = "OP_SELLSTOP";  // - sell stop pending order.
}

string Position::inspect() {
  string str;
  str  = "TicketId          = "+IntegerToString(TicketId) + "\n";
  str += "Symbol            = "+Symbol + "\n";
  str += "Side              = "+EnumToString(Side) + "\n";
  str += "OneRpips          = "+IntegerToString(OneRpips) + "\n";
  str += "RewardPips          = "+IntegerToString(RewardPips) + "\n";
  str += "OrderEntered      = "+string(OrderEntered) + "\n";
  str += "OrderOpened       = "+string(OrderOpened) + "\n";
  str += "OrderClosed       = "+string(OrderClosed) + "\n"; 
  str += "OpenPrice         = "+DoubleToStr(OpenPrice,Digits) + "\n";
  str += "ClosePrice        = "+DoubleToStr(ClosePrice,Digits) + "\n";
  str += "StopPrice         = "+DoubleToStr(StopPrice,Digits) + "\n";
  str += "TakeProfitPrice   = "+DoubleToStr(TakeProfitPrice,Digits) + "\n";
  str += "LotSize           = "+DoubleToStr(LotSize,2) + "\n";
  str += "OrderType         = "+orderType_toHuman(OrderType) + "\n";
  str += "IsPending         = "+string(IsPending) + "\n";
  str += "Reference         = "+Reference + "\n";
  str += "Magic             = "+IntegerToString(Magic) + "\n";
  str += "Expiration        = "+string(Expiration) + "\n";
  str += "ArrowColor        = "+IntegerToString(ArrowColor) + "\n";
  str += "SideX             = "+IntegerToString(SideX) + "\n";
  return(str);
}
/******************************************* 

ENUM_ORDER_TYPE

ORDER_TYPE_BUY             Market Buy order
ORDER_TYPE_SELL            Market Sell order
ORDER_TYPE_BUY_LIMIT       Buy Limit pending order
ORDER_TYPE_SELL_LIMIT      Sell Limit pending order
ORDER_TYPE_BUY_STOP        Buy Stop pending order
ORDER_TYPE_SELL_STOP       Sell Stop pending order
ORDER_TYPE_BUY_STOP_LIMIT  Upon reaching the order price, a pending Buy Limit order is placed at the StopLimit price
ORDER_TYPE_SELL_STOP_LIMIT Upon reaching the order price, a pending Sell Limit order is placed at the StopLimit price
ORDER_TYPE_CLOSE_BY        Order to close a position by an opposite one

*******************************************/
