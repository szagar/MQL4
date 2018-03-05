//+------------------------------------------------------------------+
//|                                            Moving Average EA.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern double PercentRiskPerPosition;

//extern 
int TakeProfit=50;
extern double R2R=3.0;
extern int StopLoss=25;
extern int FastMA=5;
extern int FastMaShift=0;
extern int FastMaMethod=0;
extern int FastMaAppliedTo=0;

extern int SlowMA=21;
extern int SlowMaShift=0;
extern int SlowMaMethod=0;
extern int SlowMaAppliedTo=0;

extern double LotSize = 0.01;
extern int MagicNumber = 1234;
double pips;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
    if (ticksize == 0.00001 || ticksize == 0.001)
      pips = ticksize*10;
    else
      pips = ticksize;

    TakeProfit = int(StopLoss*R2R);
   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }


int start()
  {
  double lots, dollarRisk;
  double PreviousFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,2);
  double CurrentFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,1);
  double PreviousSlow = iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,2);
  double CurrentSlow = iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,1);

  dollarRisk = AccountFreeMargin()*PercentRiskPerPosition/100.0;
  Print("dollarRisk="+DoubleToStr(dollarRisk,Digits));
  lots = dollarRisk / (StopLoss*pips); 
  lots *= Point;
  lots = MathRound(lots/MarketInfo(NULL,MODE_LOTSTEP)) * MarketInfo(NULL,MODE_LOTSTEP);
  Print("lots="+DoubleToStr(lots,Digits));
  
  if(PreviousFast<PreviousSlow && CurrentFast>CurrentSlow)
    if(OrdersTotal()==0)
      OrderSend(Symbol(),OP_BUY,lots,Ask,3,Ask-(StopLoss*pips),Ask+(TakeProfit*pips),NULL,MagicNumber,0,Green);
  if(PreviousFast>PreviousSlow && CurrentFast<CurrentSlow)
    if(OrdersTotal()==0)
      OrderSend(Symbol(),OP_SELL,lots,Bid,3,Bid+(StopLoss*pips),Bid-(TakeProfit*pips),NULL,MagicNumber,0,Red);
  return(0);
}     
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   start();
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
