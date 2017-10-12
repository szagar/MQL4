//+------------------------------------------------------------------+
//|                                              position_sizing.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <zts\daily_pnl.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

//+---------------------------------------------------------------------------+
//| The function calculates the postion size based on stop loss level, risk   |
//| per trade and account balance.                                                               |
//+---------------------------------------------------------------------------+
double CalcTradeSize(double percent2risk)
{
  Alert("Calculating position sizing");
  //PercentRiskPerPosition
  Alert("Account equity = " + string(AccountEquity()));
  Alert("Account free margin = " + string(AccountFreeMargin()));
  Alert("Account credit= " + string(AccountCredit()));
  //Alert("Account free margin = " + AccountInfoDouble());
  //Alert("Account free margin = " + AccountInfoString());
  //Alert("Account free margin = " + AccountInfoInteger());
  Alert("Account leverage = " + string(AccountLeverage()));
  Alert("Account margin = " + string(AccountMargin()));
  Alert("Account profit = " + string(AccountProfit()));
  Alert("Account stopout mode = " + string(AccountStopoutMode()));
  Alert("Account stopout level = " + string(AccountStopoutLevel()));
  Alert("Account balance = " + string(AccountBalance()));
  Print("Account balance = ",AccountBalance());

  double dollarRisk = (AccountFreeMargin()+ LockedInProfit()) * percent2risk;

  double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
  double LotSize = dollarRisk /(stopLoss * nTickValue);
  LotSize = LotSize * Point;
  LotSize=MathRound(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);
  int stopLossPips  = stopLoss / Point;

  //If the digits are 3 or 5 we normalize multiplying by 10
  if(Digits==3 || Digits==5)
  {
    nTickValue=nTickValue*10;
    stopLossPips = stopLossPips / 10;
  }  

  Alert(string(stopLossPips) + " = " + string(stopLoss) + " / " + string(Point) + " / " + string(nTickValue));
  
  
  Alert("Account free margin = " + string(AccountFreeMargin()) + "\n"
        "point value in the quote currency = " + DoubleToString(Point,5) + "\n"
        "broker lot size = " + string(MarketInfo(Symbol(),MODE_LOTSTEP)) + "\n"
        "PercentRiskPerPosition = " + string(PercentRiskPerPosition*100.0) + "%" + "\n"
        "dollarRisk = " + string(dollarRisk) + "\n"
        "stop loss = " + string(stopLoss) +", " + string(stopLossPips) + " pips" + "\n"
        "locked in = " + string(LockedInPips()) + "(pips)\n"
        "LotSize = " + string(LotSize) + "\n"
        "Ask = " + string(Ask) + "\n"
        "Bid = " + string(Bid) + "\n"
        "Close = " + string(Close[0]) + "\n"
        "MarketInfo(Symbol(),MODE_TICKVALUE) = " + string(MarketInfo(Symbol(),MODE_TICKVALUE)));
  return(LotSize);
}
