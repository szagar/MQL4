//+------------------------------------------------------------------+
//|                                                    The Finch.mq4 |
//|                                       Copyright 2016, Rob Booker |
//|                                             http://robbooker.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Rob Booker"
#property link      "http://robbooker.com"
#property strict

input string WARNING = "Using a robot carries risk, use on demo account FIRST";
input string NOTE = "Download the Robots guide: http://bit.ly/2c2yYnL";
input int Magic =12345;
input int CandlesBack = 30;
input int Slippage=5;
input int Max_Spread_Pips=5;

input double First_Trade_Lots=0.01;
input double Second_Trade_Lots=0.03;

input int Pips_To_Trade_2 = 70;

input string Stop_Type="Default no stop loss";
input double Stop_Loss_In_Dollars=0.0;

input string Profit_In_Dollars = "Profit Targets in Dollar Value format";
input double First_Trade_Profit_In_Dollars=1.3;
input double Second_Trade_Profit_In_Dollars=1.3;

input bool Break_Even = false;
input double Break_Even_At_Profit = 6.5;

input int RSIPeriod = 21;
input int MomentumPeriod = 20;

input bool Mail_Alert = false;
input bool PopUp_Alert = false;
input bool Sound_Alert = false;
input bool SmartPhone_Notifications=false;

double UsePoint;
int UseSlippage;

double Order_Stop;

double CloseOne;

int LastKDB;
int LastKDS;

double Order_Profit;

int Order_Type = 2;
double PriceForBuy=9999.0;
double PriceForSell=0.0;


bool BreakEven=false;

int TotalTrades=0;

bool BuysNotAllowed=false;
bool SellsNotAllowed=false;

int OnInit()
{
   UsePoint = PipPoint();
   UseSlippage = GetSlippage();


return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{

}

void OnTick()
{
   CheckProfit();

   if(TotalTrades==2) return;
   if(CloseOne!=Close[1])
   {
      if(!BuysNotAllowed && Order_Type!=1 && Close[0]<=PriceForBuy && RSIBuyCheck(1)) OpenTrade("Buy");
      if(!SellsNotAllowed && Order_Type!=0 && Close[0]>=PriceForSell && RSISellCheck(1)) OpenTrade("Sell");

      CloseOne=Close[1];
   }
}
double PipPoint()
{
   if(Digits() == 2 || Digits() == 3) return(0.01);
   else if(Digits() == 4 || Digits() == 5) return(0.0001);
   return(Point);
}
int GetSlippage()
{
   if(Digits() == 2 || Digits() == 4) return(Slippage);
   else if(Digits() == 3 || Digits() == 5) return(Slippage*10);
   return(Digits());
}
void CheckProfit()
{
   double Profits=0.0;
   TotalTrades=0;
   for(int x=0;x<OrdersTotal();x++)
   {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderMagicNumber()!=Magic) continue;
         if(OrderSymbol()!=Symbol()) continue;
         
         Profits+=OrderProfit();
         TotalTrades=TotalTrades+1;
         
         if(OrderType()==0) {Order_Type=OrderType();PriceForBuy=OrderOpenPrice()-(Pips_To_Trade_2*UsePoint);}
         if(OrderType()==1) {Order_Type=OrderType();PriceForSell=OrderOpenPrice()+(Pips_To_Trade_2*UsePoint);}
         
      }
   }

   if(TotalTrades==0) {BreakEven=false;Order_Type=2;return;}
   
   if(TotalTrades==1 && Profits>=First_Trade_Profit_In_Dollars) {Print("Profit-1 is "+DoubleToStr(Profits,2));CloseAllTrades();return;}
   if(TotalTrades>=2 && Profits>=Second_Trade_Profit_In_Dollars) {Print("Profit-2 is "+DoubleToStr(Profits,2));CloseAllTrades();return;}

   if(Stop_Loss_In_Dollars>0 && TotalTrades>0 && Profits<=(Stop_Loss_In_Dollars*(-1))) {Print("Profit is "+DoubleToStr(Profits,2));CloseAllTrades();return;}

   if(Break_Even && !BreakEven && Profits>=Break_Even_At_Profit) {Print("Finch Break Even Begin");BreakEven=true;}
   
   if(Break_Even && BreakEven && Profits<=0) {CloseAllTrades();return;}
return;
}
int OpenTrades()
{
   int thetotal=0;
   for(int x=0;x<OrdersTotal();x++)
   {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderMagicNumber()!=Magic) continue;
         if(OrderSymbol()!=Symbol()) continue;
         
         thetotal++;
      }
   }
   RefreshRates();
   return(thetotal);
}   
void CloseAllTrades()
{
   Order_Type=2;
   
   BreakEven=false;
   
   PriceForBuy=9999.0;
   PriceForSell=0.0;

   while(OpenTrades()>0)
   {   
      for(int x=0;x<OrdersTotal();x++)
      {
         if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
         {
            if(OrderMagicNumber()!=Magic) continue;
            if(OrderSymbol()!=Symbol()) continue;
            
            if(OrderType()==0) bool c1 = OrderClose(OrderTicket(),OrderLots(),Bid,UseSlippage);
            if(OrderType()==1) bool c2 = OrderClose(OrderTicket(),OrderLots(),Ask,UseSlippage);
            
            x--;
            
            if(GetLastError()==136) continue;
         }
      }
      Sleep(1000);
      RefreshRates();
   }
return;
}
void OpenTrade(string Type)
{
   double TheSpread=MarketInfo(Symbol(),MODE_SPREAD);
   if(Digits()==3 || Digits()==5) TheSpread = MarketInfo(Symbol(),MODE_SPREAD)/10;
   
   if(TheSpread>Max_Spread_Pips) {Print("Spread too large, can't place trade");return;}
   
   double Lots = First_Trade_Lots;
   if(TotalTrades==1) Lots=Second_Trade_Lots;
   
   if(Type=="Buy")
   {      
      int Buy = OrderSend(Symbol(),OP_BUY,Lots,Ask,UseSlippage,0,0,"Buy Finch: "+Symbol(),Magic,0,0);

      if(GetLastError()==4110) {BuysNotAllowed=true;return;}

      PriceForBuy=Close[0]-(Pips_To_Trade_2*UsePoint);
      
      Order_Type=0;

      SendAlert("New Finch Buy Trade on the "+Symbol());
   }
   if(Type=="Sell")
   {
      int Sell = OrderSend(Symbol(),OP_SELL,Lots,Bid,UseSlippage,0,0,"Sell Finch: "+Symbol(),Magic,0,0);

      if(GetLastError()==4111) {SellsNotAllowed=true;return;}
         
      PriceForSell=Close[0]+(Pips_To_Trade_2*UsePoint);
      
      Order_Type=1;
      
      SendAlert("New Finch Sell Trade on the "+Symbol());
   }
return;
}
bool RSISellCheck(int Loc)
{
   double RSIMain = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,Loc);
   if(RSIMain < 50) return(false);
   for(int x=Loc;x<=Loc+2;x++)
   {
      if(High[x]>High[Loc])return(false);
   }
   for(int y=Loc+4;y<(Loc+CandlesBack);y++)
   {
      if(High[y]>High[Loc]) break;
      int s=y;
      for(int z=y-2;z<=y+2;z++)
      {
         if(High[z]>High[y]){y++; break;}
      }
      if(s!=y){y--; continue;}
      bool OB=false;
      for(int k=Loc;k<=y;k++)
      {
         double RSIOB = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,k);
         if(RSIOB>70) {OB=true; break;}
      }
      if(OB==false) continue;
      double Mom1=iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,Loc);
      double Mom2=iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,y);
      if(Mom1>Mom2) continue;
      LastKDS=y;
      return(true);
   }
   return(false);
}
bool RSIBuyCheck(int Loc)
{
   double RSIMain = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,Loc);
   if(RSIMain > 50) return(false);
   for(int x=Loc;x<=Loc+2;x++)
   {
      if(Low[x]<Low[Loc])return(false);
   }
   for(int y=Loc+4;y<(Loc+CandlesBack);y++)
   {
      if(Low[y]<Low[Loc]) break;
      int s=y;
      for(int z=y-2;z<=y+2;z++)
      {
         if(Low[z]<Low[y]){y++; break;}
      }
      if(s!=y){y--; continue;}
      bool OB=false;
      for(int k=Loc;k<=y;k++)
      {
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
void SendAlert(string Message)
{
   if(Mail_Alert) SendMail("New Finch Alert",Message);
   if(PopUp_Alert) Alert(Message);
   if(Sound_Alert) PlaySound("alert.wav");
   if(SmartPhone_Notifications) SendNotification(Message);
   return;
}