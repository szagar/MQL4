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
#include <zts\common.mqh>
#include <zts\help_tools.mqh>

double CalcTradeSize(Account *_account, double _stopLoss, double percent2risk=0.5) {
  Debug("Calculating position sizing");
  Debug(__FUNCTION__+": CalcTradeSize("+string(_stopLoss)+","+string(percent2risk)+")");
  double freeMargin = _account.freeMargin();    //  AccountFreeMargin() 
  double dollarRisk = (freeMargin + LockedInProfit()) * percent2risk/100.0;
  //double oneR = _stopLoss * BaseCcyTickValue * points2decimal_factor(Symbol());
  double oneR = _stopLoss * BaseCcyTickValue;
 
  Debug("percent2risk="+string(percent2risk));
  Debug("freeMargin="+string(freeMargin));   // 10,000
  Debug("dollarRisk="+string(dollarRisk));   // 10,000
  Debug("_stopLoss="+string(_stopLoss));     // 10
  Debug("BaseCcyTickValue="+string(BaseCcyTickValue));  // 1
  Debug("OnePoint="+DoubleToString(OnePoint,8));   // 
  Debug("Point="+DoubleToString(Point,8));   // 0.00001
  Debug("points2decimal_factor("+Symbol()+")="+DoubleToString(points2decimal_factor(Symbol()),8));   // 0.00001
  Debug("oneR="+string(oneR));
 
  double lotSize = dollarRisk / oneR * Point;  //    / 100000.0;
  Debug("lotSize="+string(lotSize));
  lotSize=MathRound(lotSize/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);
  Debug("lotSize="+string(lotSize));

  return(lotSize);
}


/**
double CalcTradeSize(double stopLoss, double PercentRiskPerPosition=0.5)
{
  double dollarRisk = (AccountFreeMargin()+ LockedIn()) * PercentRiskPerPosition/100.0;

  double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
  double LotSize = dollarRisk /(stopLoss * nTickValue);
  Debug("Calculating position sizing");
  //Debug(LotSize + " = " + dollarRisk + " /(" + stopLoss + " * " + nTickValue + ")");
  LotSize = LotSize * Point;
  LotSize=MathRound(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);

  return(LotSize);
}
**/
