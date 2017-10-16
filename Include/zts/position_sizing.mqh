//+------------------------------------------------------------------+
//|                                              position_sizing.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <zts\daily_pnl.mqh>
#include <zts\log_defines.mqh>

double CalcTradeSize(double percent2risk) {
  if (DEBUG_ANALYTICS) {
    string str = "Calculating position sizing"; //  + "\n" +
    //             AccountInfo();
    LOG(str);
  }

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
  
  if (DEBUG_ANALYTICS) {
     string str = "Account free margin = " + string(AccountFreeMargin()) + "\n"
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
        "MarketInfo(Symbol(),MODE_TICKVALUE) = " + string(MarketInfo(Symbol(),MODE_TICKVALUE));
    LOG(str);
  }
  return(LotSize);
}
