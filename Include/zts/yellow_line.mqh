//+------------------------------------------------------------------+
//|                                                  yellow_line.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <Position.mqh>
#include <Broker.mqh>
//#include <errordescription.mqh>
#include <zts\oneR.mqh>
#include <zts\trade_type.mqh>
#define LOG_LEVEL set
#define LOG_DEBUG set
#include <zts\common.mqh>
#include <zts\order_tools.mqh>
string Prefix = "PAT_";
//Broker * broker;

void cdmLong(Broker *broker, int offset=1) {
  double priceLevel = iLow(NULL,0,offset);
  PlotYellowLine(priceLevel);
  ClosePendingLimitOrders(Symbol());
  CreatePendingLimitOrder(broker, priceLevel, OP_BUYLIMIT);
  SetTradeTypeObj("CDM");
}

void cdmShort(Broker *broker, int offset=1) {
  double priceLevel = iHigh(NULL,0,offset);
  PlotYellowLine(priceLevel);
  ClosePendingLimitOrders(Symbol());
  CreatePendingLimitOrder(broker, priceLevel, OP_SELLLIMIT);
  SetTradeTypeObj("CDM");
}

void PlotYellowLine(double priceLevel, int barShift = 1) {
  datetime ylTime = iTime(NULL, 0,barShift);
  int timeOffset = 15*60;
  PlotHorizontalSegment(ylTime - timeOffset, ylTime + timeOffset, priceLevel, Yellow);
}

void PlotHorizontalSegment(datetime timeStart, datetime timeEnd, double priceLevel, color lineColor = Red)
{
  string trendlineName = Prefix + "YellowLine";

  if (ObjectFind(0, trendlineName) == 0) ObjectDelete(0, trendlineName);
  ObjectCreate(0, trendlineName, OBJ_TREND, 0, timeStart, priceLevel, timeEnd, priceLevel);
  ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, lineColor);
  ObjectSet(trendlineName, OBJPROP_RAY, false);
}

void CreatePendingLimitOrder(Broker *broker, double limitPrice, int operation, bool allowForSpread=false, int margin=0, int spread=0) {
  string normalizedSymbol = broker.NormalizeSymbol(Symbol());
  Position * trade = new Position();
  trade.IsPending = true;
  trade.OpenPrice = limitPrice;
  trade.OrderType = operation;
  trade.Symbol = broker.NormalizeSymbol(Symbol());
  trade.Reference = __FILE__;
  
  double stopLoss = LookupStopPips(normalizedSymbol) * OnePoint;
  trade.LotSize = CalcTradeSize(stopLoss);
  
  //SetTradeTypeObj("CMD");
  broker.CreateOrder(trade);
  delete(trade); 
}

//+---------------------------------------------------------------------------+
//| The function calculates the amount, in USD, secured with stop losses in   |
//| open positions.                                                               |
//+---------------------------------------------------------------------------+
double LockedIn()
{
  return(0.0);
}

//+---------------------------------------------------------------------------+
//| The function calculates the postion size based on stop loss level, risk   |
//| per trade and account balance.                                                               |
//+---------------------------------------------------------------------------+
double CalcTradeSize(double stopLoss, double PercentRiskPerPosition=0.5)
{
  double dollarRisk = (AccountFreeMargin()+ LockedIn()) * PercentRiskPerPosition/100.0;

  double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
  double LotSize = dollarRisk /(stopLoss * nTickValue);
  Debug("Calculating position sizing");
  Debug(LotSize + " = " + dollarRisk + " /(" + stopLoss + " * " + nTickValue + ")");
  LotSize = LotSize * Point;
  LotSize=MathRound(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);
  int stopLossPips  = stopLoss / Point;

  //If the digits are 3 or 5 we normalize multiplying by 10
  if(Digits==3 || Digits==5) {
    nTickValue=nTickValue*10;
    stopLossPips = stopLossPips / 10;
  }  

  Debug(string(stopLossPips) + " = " + string(stopLoss) + " / " + string(Point) + " / " + string(nTickValue));
  
  
  Debug("Account free margin = " + string(AccountFreeMargin()) + "\n"
        "point value in the quote currency = " + DoubleToString(Point,5) + "\n"
        "broker lot size = " + string(MarketInfo(Symbol(),MODE_LOTSTEP)) + "\n"
        "PercentRiskPerPosition = " + string(PercentRiskPerPosition) + "%" + "\n"
        "dollarRisk = " + string(dollarRisk) + "\n"
        "stop loss = " + string(stopLoss) +", " + string(stopLossPips) + " pips" + "\n"
        "locked in = " + string(LockedIn()) + "\n"
        "LotSize = " + string(LotSize) + "\n"
        "Ask = " + string(Ask) + "\n"
        "Bid = " + string(Bid) + "\n"
        "Close = " + string(Close[0]) + "\n"
        "MarketInfo(Symbol(),MODE_TICKVALUE) = " + string(MarketInfo(Symbol(),MODE_TICKVALUE)));
  return(LotSize);
}
