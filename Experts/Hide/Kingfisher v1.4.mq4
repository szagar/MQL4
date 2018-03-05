//+------------------------------------------------------------------+
//|                                                Kingfisher v1.mq4 |
//|                                       Copyright 2016, Rob Booker |
//|                                       http://thebookerreport.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Rob Booker"
#property link      "http://thebookerreport.com"
#property version   "1.00"
#property strict

extern int Magic = 12345;
extern int Slippage=5;
extern int Max_Spread_Pips=5;
extern int RSI_Period = 28;
extern int Pips_To_Trade2 = 15;
extern double Lots_Trade1 = 0.01;
extern double Lots_Trade2 = 0.03;
extern double Profit_Trade1 = 1.0;
extern double Profit_Trade2 = 5.0;
extern bool Use_Stop_Loss = false;
extern double Stop_Loss_In_Currency = (-10.0);
extern bool Use_Break_Even = false;
extern double Break_Even_Profit = 10.0;
extern double RSI_Overbought = 70;
extern double RSI_Oversold = 30;



int Max_Trades = 2;
double PriceForNextBuy=9999.0;
double PriceForNextSell=0.0;
double PriceForNext=0.0;

double UsePoint;
int UseSlippage;
int TradeType=2;
int TradesTotal=0;
double Profits=0.0;

bool BrokeIt=false;

double Open1;
double Open2;

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

   if(TradesTotal>=Max_Trades) return;
      
   double RSI1 = iRSI(Symbol(),0,RSI_Period,PRICE_CLOSE,1);
   double RSI2 = iRSI(Symbol(),0,RSI_Period,PRICE_CLOSE,2);

   if(Open1!=Open[1])
   {
      if(TradeType!=0 && RSI1>=RSI_Overbought && RSI2<RSI_Overbought && Close[0]>=PriceForNextSell) SellTrade();
      if(TradeType!=1 && RSI1<=RSI_Oversold && RSI2>RSI_Oversold && Close[0]<=PriceForNextBuy) BuyTrade();
      Open1=Open[1];
   }
}
void CheckProfit()
{
   Profits=0.0;
   TradesTotal=0;
   for(int x=0;x<OrdersTotal();x++)
   {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderMagicNumber()!=Magic) continue;
         if(OrderSymbol()!=Symbol()) continue;
         if(OrderCloseTime()!=0) continue;
         
         Profits+=OrderProfit();
         TradesTotal=TradesTotal+1;
         TradeType=OrderType();
      }
   }
   if(TradesTotal==1 && Profits>=Profit_Trade1) CloseAllTrades();
   if(TradesTotal>1 && Profits>=Profit_Trade2) CloseAllTrades();
   
   if(Use_Break_Even && !BrokeIt && Profits>=Break_Even_Profit) BrokeIt=true;
   if(Use_Break_Even && BrokeIt && Profits<=0.0) CloseAllTrades();
   
   if(Use_Stop_Loss && Profits<=Stop_Loss_In_Currency) CloseAllTrades();

   return;
}
void CloseAllTrades()
{
   BrokeIt=false;
   PriceForNextBuy=9999.0;
   PriceForNextSell=0.0;
   TradesTotal=0;
   TradeType=2;
   
   for(int x=0;x<OrdersTotal();x++)
   {
      if(OrderSelect(x,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderMagicNumber()!=Magic) continue;
         if(OrderSymbol()!=Symbol()) continue;
         
         if(OrderType()==0) bool c1 = OrderClose(OrderTicket(),OrderLots(),Bid,10,clrRed);
         if(OrderType()==1) bool c2 = OrderClose(OrderTicket(),OrderLots(),Ask,10,clrGreen);
         
         x--;       
      }
   }

   return;
}
double PipPoint()
{
   if(Digits() == 2 || Digits() == 3) return(0.01);
   else if(Digits() == 4 || Digits() == 5) return(0.0001);
   return(Point);
}
void SellTrade()
{
   double TheSpread=MarketInfo(Symbol(),MODE_SPREAD);
   
   if(Digits()==3 || Digits()==5) TheSpread = MarketInfo(Symbol(),MODE_SPREAD)/10;
   
   if(TheSpread>Max_Spread_Pips) {Print("Spread too large, can't place trade");return;}

   PriceForNextSell=Close[0]+(Pips_To_Trade2*UsePoint);
   
   TradeType=1;
   double Lots=Lots_Trade1;
   
   if(TradesTotal>0) Lots=Lots_Trade2;
   
   bool Sell = OrderSend(Symbol(),OP_SELL,Lots,Bid,10,0,0,"Kingfisher Sell",Magic,0,clrRed);

   return;
}
void BuyTrade()
{
   double TheSpread=MarketInfo(Symbol(),MODE_SPREAD);
   
   if(Digits()==3 || Digits()==5) TheSpread = MarketInfo(Symbol(),MODE_SPREAD)/10;
   
   if(TheSpread>Max_Spread_Pips) {Print("Spread too large, can't place trade");return;}

   PriceForNextBuy=Close[0]-(Pips_To_Trade2*UsePoint);

   TradeType=0;
   
   double Lots=Lots_Trade1;
   
   if(TradesTotal>0) Lots=Lots_Trade2;

   bool Buy = OrderSend(Symbol(),OP_BUY,Lots,Ask,10,0,0,"Kingfisher Buy",Magic,0,clrGreen);

   return;
}
int GetSlippage()
{
   if(Digits == 2 || Digits == 4) {return(Slippage);}
   else if(Digits == 3 || Digits == 5) {return(Slippage * 10);}
   return(Digits);
}