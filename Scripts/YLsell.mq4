//+------------------------------------------------------------------+
//|                                                        YLbuy.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, SSTK Assoc"
#property link      "https://"
#property version   "1.00"
#property strict

int debug = 0x0040;
#define DEBUG_EXIT  ((debug & 0x0001) == 0x0001)
#define DEBUG_GLOBAL  ((debug & 0x0002) == 0x0002)
#define DEBUG_ENTRY ((debug & 0x0004) == 0x0004)
#define DEBUG_CONFIG ((debug & 0x0008) == 0x0008)
#define DEBUG_ORDER ((debug & 0x0010) == 0x0010)
#define DEBUG_OANDA ((debug & 0x0020) == 0x0020)
#define DEBUG_TICK  ((debug & 0x0040) == 0x0040)
#define DEBUG_ANALYTICS  ((debug & 0x0040) == 0x0040)
#ifndef LOG
  #define LOG(text)  Print(__FILE__,"(",__LINE__,") :",text)
#endif

#include <Position.mqh>
#include <Broker.mqh>
//#include <errordescription.mqh>
#include <zts\oneR.mqh>
#include <zts\trade_type.mqh>

string Prefix = "PAT_";
double AdjPoint;
Broker * broker;
double stopLoss;

//+------------------------------------------------------------------+
//| Script program start function                                    |
void OnStart() {
  int FiveDig;
  if(Digits==5||Digits==3)
      FiveDig = 10;
  else
      FiveDig = 1;
  AdjPoint = Point * FiveDig;
   
  broker = new Broker();
  cdmShort();
  
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;
}

void cdmShort() {
  double priceLevel = iHigh(NULL,0,1);
  PlotYellowLine(priceLevel);
  CreatePendingLimitOrder(priceLevel, OP_SELLLIMIT);
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

void CreatePendingLimitOrder( double limitPrice, int operation, bool allowForSpread=false, int margin=0, int spread=0) {
  string normalizedSymbol = broker.NormalizeSymbol(Symbol());
  Position * trade = new Position();
  trade.IsPending = true;
  trade.OpenPrice = limitPrice;
  trade.OrderType = operation;
  trade.Symbol = broker.NormalizeSymbol(Symbol());
  trade.Reference = __FILE__;
  
  stopLoss = LookupStopPips(normalizedSymbol) * AdjPoint;
  trade.LotSize = CalcTradeSize();
  
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
double CalcTradeSize(double PercentRiskPerPosition=0.5)
{
  double dollarRisk = (AccountFreeMargin()+ LockedIn()) * PercentRiskPerPosition/100.0;

  double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
  double LotSize = dollarRisk /(stopLoss * nTickValue);
  if (DEBUG_ANALYTICS) {
    LOG("Calculating position sizing");
    LOG(LotSize + " = " + dollarRisk + " /(" + stopLoss + " * " + nTickValue + ")");
  }
  LotSize = LotSize * Point;
  LotSize=MathRound(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);
  int stopLossPips  = stopLoss / Point;

  //If the digits are 3 or 5 we normalize multiplying by 10
  if(Digits==3 || Digits==5) {
    nTickValue=nTickValue*10;
    stopLossPips = stopLossPips / 10;
  }  

  LOG(string(stopLossPips) + " = " + string(stopLoss) + " / " + string(Point) + " / " + string(nTickValue));
  
  
  LOG("Account free margin = " + string(AccountFreeMargin()) + "\n"
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

