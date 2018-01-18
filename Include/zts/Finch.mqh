#property strict

extern string commentString_25 = ""; //*****************************************
extern string commentString_26 = ""; //Finch Settings
extern int CandlesBack = 30;
extern int Max_Spread_Pips=5;

extern double First_Trade_Lots=0.01;
extern double Second_Trade_Lots=0.03;

extern int Pips_To_Trade_2 = 70;

extern string Stop_Type="Default no stop loss";
extern double Stop_Loss_In_Dollars=0.0;

extern string Profit_In_Dollars = "Profit Targets in Dollar Value format";
extern double First_Trade_Profit_In_Dollars=1.3;
extern double Second_Trade_Profit_In_Dollars=1.3;

extern bool Break_Even = false;
extern double Break_Even_At_Profit = 6.5;

extern int RSIPeriod = 21;
extern int MomentumPeriod = 20;
extern string commentString_27 = ""; //*****************************************

#include<zts/notify.mqh>

class Finch : public Setup {
private:
  void CheckProfit();
  bool RSIBuyCheck(int Loc);
  bool RSISellCheck(int Loc);
  int OpenTrades();
  bool OpenTrade(string Type);
  void CloseAllTrades();

  double Order_Stop;
  double CloseOne;

  int LastKDB;
  int LastKDS;

  double Order_Profit;

  int Order_Type;
  double PriceForBuy;
  double PriceForSell;
  bool BreakEven;
  //int TotalTrades;
  bool BuysNotAllowed;
  bool SellsNotAllowed;

public:
  Finch(string _symbol,Enum_SIDE _side);
  void OnInit();
  void OnTick();
};

void Finch::Finch(string _symbol,Enum_SIDE _side):Setup(_symbol,_side) {
  strategyName = "Finch";
  roboID = magic.encodeStrategyName(strategyName);
  side = _side;
  BuysNotAllowed=false;
  SellsNotAllowed=false;
  if(side == Long) SellsNotAllowed = true;
  if(side == Short) BuysNotAllowed = true;
  callOnTick = true;
}

void Finch::OnInit() {
  Order_Type = 2;
  PriceForBuy=9999.0;
  PriceForSell=0.0;
  BreakEven=false;
  tradeNumber=0;
}

void Finch::OnTick() {
  //Debug4(__FUNCTION__,__LINE__,"Entered");
  CheckProfit();
  //Debug4(__FUNCTION__,__LINE__,"1");
  if(tradeNumber==2) return;
  //Debug4(__FUNCTION__,__LINE__,"2");
  if(CloseOne!=Close[1]) {
    //Debug4(__FUNCTION__,__LINE__,"2");
    if(!BuysNotAllowed && Order_Type!=1 && Close[0]<=PriceForBuy && RSIBuyCheck(1))
      OpenTrade("Buy");
    if(!SellsNotAllowed && Order_Type!=0 && Close[0]>=PriceForSell && RSISellCheck(1))
      OpenTrade("Sell");
    CloseOne=Close[1];
  }
  //Debug4(__FUNCTION__,__LINE__,"CloseOne="+string(CloseOne));
}

void Finch::CheckProfit() {
  //Debug4(__FUNCTION__,__LINE__,"Entered");
  double Profits=0.0;
  tradeNumber=0;
  for(int x=0;x<OrdersTotal();x++) {
    //Debug4(__FUNCTION__,__LINE__,"loop");
    if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)) {
      //Debug4(__FUNCTION__,__LINE__,"roboID="+IntegerToString(roboID));
      //Debug4(__FUNCTION__,__LINE__,"OrderMagicNumber()="+string(OrderMagicNumber()));
      //Debug4(__FUNCTION__,__LINE__,"magic.roboID(OrderMagicNumber())="+IntegerToString(magic.roboID(OrderMagicNumber())));
      if(magic.roboID(OrderMagicNumber()) != roboID) continue;
      //Debug4(__FUNCTION__,__LINE__,"1");
      if(OrderSymbol()!=Symbol()) continue;
         
      Profits+=OrderProfit();
      tradeNumber=tradeNumber+1;
      //Debug4(__FUNCTION__,__LINE__,"tradeNumber="+IntegerToString(tradeNumber));
         
      if(OrderType()==0) {
        Order_Type=OrderType();     // Buy
        PriceForBuy=OrderOpenPrice()-(Pips_To_Trade_2*OnePoint);
      }
      if(OrderType()==1) {
        Order_Type=OrderType();     // Sell
        PriceForSell=OrderOpenPrice()+(Pips_To_Trade_2*OnePoint);
      }
    }
  }

  //Debug4(__FUNCTION__,__LINE__,"tradeNumber="+string(tradeNumber)+"  Order_Type="+string(Order_Type)+"  Profits="+string(Profits));

  //Debug4(__FUNCTION__,__LINE__,"2");
  if(tradeNumber==0) {
    BreakEven=false;
    Order_Type=2;                 // Buy Limit
    return;
  }
  //Debug4(__FUNCTION__,__LINE__,"3");
  if(tradeNumber==1 && Profits>=First_Trade_Profit_In_Dollars) {
    Print("Profit-1 is "+DoubleToStr(Profits,2));
    //Debug4(__FUNCTION__,__LINE__,"call CloseAllTrades");
    CloseAllTrades();
    return;
  }
  //Debug4(__FUNCTION__,__LINE__,"3");
  if(tradeNumber>=2 && Profits>=Second_Trade_Profit_In_Dollars) {
    Print("Profit-2 is "+DoubleToStr(Profits,2));
    //Debug4(__FUNCTION__,__LINE__,"call CloseAllTrades");
    CloseAllTrades();
    return;
  }
  //Debug4(__FUNCTION__,__LINE__,"4");
  if(Stop_Loss_In_Dollars>0 && tradeNumber>0 && Profits<=(Stop_Loss_In_Dollars*(-1))) {
    Print("Profit is "+DoubleToStr(Profits,2));
    //Debug4(__FUNCTION__,__LINE__,"call CloseAllTrades");
    CloseAllTrades();
    return;
  }
  //Debug4(__FUNCTION__,__LINE__,"5");
  if(Break_Even && !BreakEven && Profits>=Break_Even_At_Profit) {
    Print("Finch Break Even Begin");
    BreakEven=true;
  }
  //Debug4(__FUNCTION__,__LINE__,"6");
  if(Break_Even && BreakEven && Profits<=0) {
    //Debug4(__FUNCTION__,__LINE__,"call CloseAllTrades");
    CloseAllTrades();
    return;
  }
  //Debug4(__FUNCTION__,__LINE__,"7");
  return;
}

int Finch::OpenTrades() {
  int thetotal=0;
  for(int x=0;x<OrdersTotal();x++) {
    if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)) {
      if(magic.roboID(OrderMagicNumber()) != roboID) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderType()>1) continue;    // smz   
      thetotal++;
    }
  }
  RefreshRates();
  return(thetotal);
}   

void Finch::CloseAllTrades() {
  Debug4(__FUNCTION__,__LINE__,"Entered");
  Order_Type=2;
   
  BreakEven=false;
   
  PriceForBuy=9999.0;
  PriceForSell=0.0;

  while(OpenTrades()>0) {   
    Debug4(__FUNCTION__,__LINE__,"OpenTrades()="+string(OpenTrades()));
    Debug4(__FUNCTION__,__LINE__,"OrdersTotal()="+string(OrdersTotal()));
    for(int x=0;x<OrdersTotal();x++) {
      Debug4(__FUNCTION__,__LINE__,"x="+string(x));
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES)) {
        Debug4(__FUNCTION__,__LINE__,"magic.roboID(OrderMagicNumber()="+string(magic.roboID(OrderMagicNumber())));
        Debug4(__FUNCTION__,__LINE__,"roboID="+string(roboID));
        Debug4(__FUNCTION__,__LINE__,"Symbol()="+Symbol());
        if(magic.roboID(OrderMagicNumber()) != roboID) continue;
        if(OrderSymbol()!=Symbol()) continue;
            
        Debug4(__FUNCTION__,__LINE__,"OrderType()="+string(OrderType()));
        if(OrderType()==0) {
          bool c1 = OrderClose(OrderTicket(),OrderLots(),Bid,UseSlippage);
          Debug4(__FUNCTION__,__LINE__,string(c1)+" = OrderClose("+string(OrderTicket())+","+string(OrderLots())+","+string(Bid)+","+string(UseSlippage)+")");
          x--;
        }
        if(OrderType()==1) {
          bool c2 = OrderClose(OrderTicket(),OrderLots(),Ask,UseSlippage);
          Debug4(__FUNCTION__,__LINE__,string(c2)+" = OrderClose("+string(OrderTicket())+","+string(OrderLots())+","+string(Ask)+","+string(UseSlippage)+")");
          x--;
        }
            
        //x--;
            
        if(GetLastError()==136) Debug4(__FUNCTION__,__LINE__,"GetLastError=136");
        if(GetLastError()==136) continue;
      }
    }
    Debug4(__FUNCTION__,__LINE__,"Sleep(1000)");
    Sleep(1000);
    RefreshRates();
  }
  return;
}

bool Finch::OpenTrade(string Type) {
  //Debug4(__FUNCTION__,__LINE__,"Entered");
  double TheSpread=MarketInfo(Symbol(),MODE_SPREAD);
  if(Digits()==3 || Digits()==5)
    TheSpread = MarketInfo(Symbol(),MODE_SPREAD)/10;
   
  if(TheSpread>Max_Spread_Pips) {
    Print("Spread too large, can't place trade");
    return(false);
  }
   
  double Lots = First_Trade_Lots;
  if(tradeNumber==1)
    Lots=Second_Trade_Lots;
   
  if(Type=="Buy") {  
    triggered = true;    
    //int Buy = OrderSend(Symbol(),OP_BUY,Lots,Ask,UseSlippage,0,0,"Buy Finch: "+Symbol(),Magic,0,0);
    //if(GetLastError()==4110) {
    //  BuysNotAllowed=true;
    //  return(false);
    //}

    PriceForBuy=Close[0]-(Pips_To_Trade_2*OnePoint);
      
    Order_Type=0;

    SendAlert("New Finch Buy Trade on the "+Symbol());
  }
  if(Type=="Sell") {
    triggered = true;
    //int Sell = OrderSend(Symbol(),OP_SELL,Lots,Bid,UseSlippage,0,0,"Sell Finch: "+Symbol(),Magic,0,0);
    //if(GetLastError()==4111) {
    //  SellsNotAllowed=true;
    //  return(false);
    //}
         
    PriceForSell=Close[0]+(Pips_To_Trade_2*OnePoint);
      
    Order_Type=1;
      
    SendAlert("New Finch Sell Trade on the "+Symbol());
  }
  return(true);
}

bool Finch::RSISellCheck(int Loc) {
  double RSIMain = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,Loc);
  if(RSIMain < 50)
    return(false);
  for(int x=Loc;x<=Loc+2;x++) {
    if(High[x]>High[Loc])
      return(false);
  }
  for(int y=Loc+4;y<(Loc+CandlesBack);y++) {
    if(High[y]>High[Loc])
      break;
    int s=y;
    for(int z=y-2;z<=y+2;z++) {
      if(High[z]>High[y]) {
        y++;
        break;
      }
    }
    if(s!=y) {
      y--;
      continue;
    }
    bool OB=false;
    for(int k=Loc;k<=y;k++) {
      double RSIOB = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,k);
      if(RSIOB>70) {
        OB=true;
        break;
      }
    }
    if(OB==false)
      continue;
    double Mom1=iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,Loc);
    double Mom2=iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,y);
    if(Mom1>Mom2) continue;
    LastKDS=y;
    return(true);
  }
  return(false);
}

bool Finch::RSIBuyCheck(int Loc) {
  double RSIMain = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,Loc);
  if(RSIMain > 50) return(false);
  for(int x=Loc;x<=Loc+2;x++) {
    if(Low[x]<Low[Loc]) return(false);
  }
  for(int y=Loc+4;y<(Loc+CandlesBack);y++) {
    if(Low[y]<Low[Loc]) break;
    int s=y;
    for(int z=y-2;z<=y+2;z++) {
      if(Low[z]<Low[y]) {y++; break;}
    }
    if(s!=y){y--; continue;}
    bool OB=false;
    for(int k=Loc;k<=y;k++) {
      double RSIOB = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,k);
      if(RSIOB<30) {OB=true; break;}
    }
    if(OB==false) continue;
    double Mom1=iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,Loc);
    double Mom2=iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,y);
    if(Mom1<Mom2) continue;
    LastKDB=y;
    return(true);
  }
  return(false);
}
