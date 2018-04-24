//+------------------------------------------------------------------+
//|                                         Knoxville Divergence.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_color7 Green
#property indicator_color8 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1

extern int CandlesBack = 30;
extern int RSIPeriod = 21;
extern string TSI = "Ergodic TSI";
extern int TSI_r = 2;
extern int TSI_s = 5;
extern int TSI_u = 8;
extern int TSI_smooth = 2;

extern int FastMAPeriod=12;
extern int SlowMAPeriod=26;
extern int SignalMAPeriod=9;
extern int KPeriod=70;
extern int DPeriod=10;
extern int Slowing=10;
extern int Stochastic_Upper=99;
extern int Stochastic_Lower=1;
extern bool Reversal_Tabs_Alerts = false;
extern bool Mail_Alert = false;
extern bool PopUp_Alert = false;
extern bool Sound_Alert = false;
extern bool SmartPhone_Notifications=false;


double UsePoint;

bool Alerts=true;
bool KAlerts=true;
double Buy[];
double Sell[];
double BuyArrow[];
double SellArrow[];
double BuyAlt[];
double SellAlt[];
double BuyAlt1[];
double SellAlt1[];
double LastKDB;
double LastKDS;
double LastKDBA;
double LastKDSA;
double LastKDBA2;
double LastKDSA2;

//---- Ergodic TSI
double ErgBuffer[];
double ema_ErgBuffer[];
double Price_Delta1_Buffer[];
double Price_Delta2_Buffer[];
double s_ema1_Buffer[];
double s_ema2_Buffer[];
double u_ema1_Buffer[];
double u_ema2_Buffer[];


int init()
{
IndicatorBuffers(16);

SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(0, Buy);
SetIndexLabel(0,"Buy Knox");

SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(1, Sell);
SetIndexLabel(1,"Sell Knox");

SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID);
SetIndexArrow(2,233);
SetIndexBuffer(2, BuyArrow);
SetIndexLabel(2,"Buy Reversal");

SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID);
SetIndexArrow(3,234);
SetIndexBuffer(3, SellArrow);
SetIndexLabel(3,"Sell Reversal");

SetIndexStyle(4,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(4, BuyAlt);
SetIndexLabel(4,"Buy Knox Alt");

SetIndexStyle(5,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(5, SellAlt);
SetIndexLabel(5,"Sell Knox Alt");

SetIndexStyle(6,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(6, BuyAlt1);
SetIndexLabel(6,"Buy Knox Alt");

SetIndexStyle(7,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(7, SellAlt1);
SetIndexLabel(7,"Sell Knox Alt");


SetIndexBuffer(8,ema_ErgBuffer);
SetIndexBuffer(9,ErgBuffer);
SetIndexBuffer(10,Price_Delta1_Buffer);
SetIndexBuffer(11,Price_Delta2_Buffer);
SetIndexBuffer(12,s_ema1_Buffer);
SetIndexBuffer(13,s_ema2_Buffer);
SetIndexBuffer(14,u_ema1_Buffer);
SetIndexBuffer(15,u_ema2_Buffer);

UsePoint = PipPoint(Symbol());

return(0);
}
int deinit()
{
return(0);
}
int start()
{   
   calculateTSI();
   int counted_bars = (IndicatorCounted()+1);
   int uncounted_bars = Bars - counted_bars;
   
   for(int j=uncounted_bars; j>=1; j--)
   {
      double MACD = iMACD(Symbol(),0,FastMAPeriod,SlowMAPeriod,SignalMAPeriod,PRICE_CLOSE,MODE_MAIN,j);
      double MACD1 = iMACD(Symbol(),0,FastMAPeriod,SlowMAPeriod,SignalMAPeriod,PRICE_CLOSE,MODE_MAIN,j+1);
      double Stoch = iStochastic(Symbol(),0,KPeriod,DPeriod,Slowing,MODE_SMA,0,MODE_MAIN,j);

      if(MACD1>0 && MACD<0 && Stoch>Stochastic_Upper)
      {
         SellArrow[j]=High[j]+(7*UsePoint);
         if(j==1 && Reversal_Tabs_Alerts) SendAlert("Sell Reversal Tab for the "+Symbol());
      }   

      if(MACD1<0 && MACD>0 && Stoch<Stochastic_Lower)
      {
         BuyArrow[j]=Low[j]-(7*UsePoint);
         if(j==1 && Reversal_Tabs_Alerts) SendAlert("Buy Reversal Tab for the "+Symbol());
      }

      RSISellCheck(j);
      RSIBuyCheck(j);
   }

return(0);
}

void calculateTSI() 
{
   int i,limit;
   double mean1, mean2;

   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(i=0; i<limit; i++) {
      //Price_Delta1_Buffer[i] = Close[i] - Close[i+r];
      //Price_Delta2_Buffer[i] = MathAbs(Close[i] - Close[i+r]);
      mean1 = (Close[i] + High[i] + Low[i]) /3;
      mean2 = (Close[i+TSI_r] + High[i+TSI_r] + Low[i+TSI_r]) /3;
      Price_Delta1_Buffer[i] = mean1 - mean2;
      Price_Delta2_Buffer[i] = MathAbs(mean1 - mean2);
   }

   for(i=0; i<limit; i++) {
      s_ema1_Buffer[i]=iMAOnArray(Price_Delta1_Buffer,Bars,TSI_s,0,MODE_EMA,i);
      s_ema2_Buffer[i]=iMAOnArray(Price_Delta2_Buffer,Bars,TSI_s,0,MODE_EMA,i);
   }

   for(i=0; i<limit; i++) {
      u_ema1_Buffer[i]=iMAOnArray(s_ema1_Buffer,Bars,TSI_u,0,MODE_EMA,i);
      u_ema2_Buffer[i]=iMAOnArray(s_ema2_Buffer,Bars,TSI_u,0,MODE_EMA,i);
   }

   for(i=0; i<limit; i++) {
      ErgBuffer[i] = 100 * u_ema1_Buffer[i] / u_ema2_Buffer[i] ;
   }

   for(i=0; i<limit; i++) {
      ema_ErgBuffer[i] = iMAOnArray(ErgBuffer,Bars,TSI_smooth,0,MODE_EMA,i);
   }
}

void RSISellCheck(int Loc)
{
   double RSIMain = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,Loc);
   if(RSIMain < 50){Sell[Loc]=EMPTY_VALUE;return;}
   for(int x=Loc;x<=Loc+2;x++)
   {
      if(High[x]>High[Loc]){Sell[Loc]=EMPTY_VALUE;return;}
   }
   for(int y=Loc+4;y<=(Loc+CandlesBack);y++)
   {
      if(Time[y]<LastKDS) bool UseKDSAlt=true;
      if(Time[y]<LastKDSA) {UseKDSAlt=false; bool UseKDSAlt1=true;}
      if(Time[y]<LastKDSA2) {UseKDSAlt1=false;}
      
      if(y==(Loc+CandlesBack)){Sell[Loc]=EMPTY_VALUE;return;}
      if(High[y]>High[Loc]) {Sell[Loc]=EMPTY_VALUE;return;}
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
      double Mom1=ErgBuffer[Loc];//iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,Loc);
      double Mom2=ErgBuffer[y];//iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,y);
      if(Mom1>Mom2) continue;

      LastKDS=Time[Loc];
      if(UseKDSAlt)LastKDSA=Time[Loc];
      if(UseKDSAlt1)LastKDSA2=Time[Loc];

      LineDraw(Loc,y,"Sell",UseKDSAlt,UseKDSAlt1);
      if(Loc==1) {SendAlert("New Knoxville Divergence Sell Setup on the "+Symbol());}
      return;
   }
}
void RSIBuyCheck(int Loc)
{
   double RSIMain = iRSI(Symbol(),0,RSIPeriod,PRICE_CLOSE,Loc);
   if(RSIMain > 50){Buy[Loc]=EMPTY_VALUE;return;}
   for(int x=Loc;x<=Loc+2;x++)
   {
      if(Low[x]<Low[Loc]){Buy[Loc]=EMPTY_VALUE;return;}
   }
   for(int y=Loc+4;y<=(Loc+CandlesBack);y++)
   {
      if(Time[y]<LastKDB) bool UseKDBAlt=true;
      if(Time[y]<LastKDBA) {UseKDBAlt=false; bool UseKDBAlt1=true;}
      if(Time[y]<LastKDBA2) {UseKDBAlt1=false;}

      if(y==(Loc+CandlesBack)){Buy[Loc]=EMPTY_VALUE;return;}
      if(Low[y]<Low[Loc]) {Buy[Loc]=EMPTY_VALUE;return;}
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
      double Mom1=ErgBuffer[Loc];//iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,Loc);
      double Mom2=ErgBuffer[y];//iMomentum(Symbol(),0,MomentumPeriod,PRICE_CLOSE,y);
      if(Mom1<Mom2) continue;

      LastKDB=Time[Loc];
      if(UseKDBAlt)LastKDBA=Time[Loc];
      if(UseKDBAlt1)LastKDBA2=Time[Loc];

      LineDraw(Loc,y,"Buy",UseKDBAlt,UseKDBAlt1);
      if(Loc==1) {SendAlert("New Knoxville Divergence Buy Setup on the "+Symbol());}
      return;
   }
}
void LineDraw(int Start, int Finish, string BuySell, bool UseAlt, bool UseAlt2)
{
   double Slope;
   if(BuySell=="Buy")
   {
      Slope=(Low[Start]-Low[Finish])/(Start-Finish);
      double StartBuy=Low[Start];
      for(int x=0;x<=(Finish-Start);x++)
      {
         StartBuy+=Slope;
         if(!UseAlt && !UseAlt2)Buy[Start+x]=StartBuy;
         if(UseAlt)BuyAlt[Start+x]=StartBuy;
         if(UseAlt2)BuyAlt1[Start+x]=StartBuy;
      }
      for(int i=Finish+1;i<Bars;i++)
      {
         if(Buy[i]==EMPTY_VALUE && !UseAlt && !UseAlt2)return;
         if(BuyAlt[i]==EMPTY_VALUE && UseAlt)return;
         if(BuyAlt1[i]==EMPTY_VALUE && UseAlt2)return;
         if(!UseAlt && !UseAlt2)Buy[i]=EMPTY_VALUE;
         if(UseAlt)BuyAlt[i]=EMPTY_VALUE;
         if(UseAlt2)BuyAlt1[i]=EMPTY_VALUE;
      }
   }
   if(BuySell=="Sell")
   {
      Slope=(High[Start]-High[Finish])/(Start-Finish);
      double StartSell=High[Start];
      for(int y=0;y<=(Finish-Start);y++)
      {
         StartSell+=Slope;
         if(!UseAlt && !UseAlt2)Sell[Start+y]=StartSell;
         if(UseAlt)SellAlt[Start+y]=StartSell;
         if(UseAlt2)SellAlt1[Start+y]=StartSell;
      }
      for(int n=Finish+1;n<Bars;n++)
      {
         if(!UseAlt && !UseAlt2 && Sell[n]==EMPTY_VALUE)return;
         if(UseAlt && SellAlt[n]==EMPTY_VALUE)return;
         if(UseAlt2 && SellAlt1[n]==EMPTY_VALUE)return;
         if(!UseAlt && !UseAlt2)Sell[n]=EMPTY_VALUE;
         if(UseAlt)SellAlt[n]=EMPTY_VALUE;
         if(UseAlt2)SellAlt1[n]=EMPTY_VALUE;
      }
   }
   return;
}
double PipPoint(string Currency)
{
int CalcDigits = MarketInfo(Currency,MODE_DIGITS);
if(CalcDigits == 2 || CalcDigits == 3) double CalcPoint = 0.01;
else if(CalcDigits == 4 || CalcDigits == 5) CalcPoint = 0.0001;
return(CalcPoint);
}
void SendAlert(string Message)
{
   if(Mail_Alert) SendMail("New Knoxville Alert",Message);
   if(PopUp_Alert) Alert(Message);
   if(Sound_Alert) PlaySound("alert.wav");
   if(SmartPhone_Notifications) SendNotification(Message);
   return;
}