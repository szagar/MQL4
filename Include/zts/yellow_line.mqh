//+------------------------------------------------------------------+
//|                                                  yellow_line.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <zts\Position.mqh>
#include <zts\Broker.mqh>
//#include <errordescription.mqh>
#include <zts\oneR.mqh>
#include <zts\trade_type.mqh>
//#define LOG_LEVEL set
//#define LOG_DEBUG set
#include <zts\common.mqh>
#include <zts\order_tools.mqh>
#include <zts\position_sizing.mqh>
#include <zts\TradeStatus.mqh>
#include <zts\MagicNumber.mqh>

string Prefix = "PAT_";
//Broker * broker;


void stalkYellowLine(Account *account, Broker *broker, int offset=1) {
  double priceLevel;
  int action;
  bool submit = false;
  TradeStatus *ts;
  ts = new TradeStatus();
  ts.loadFromChart();
  if(ts.setupType!="CDM"){
    Print(__FUNCTION__,": most be in CDM to stalk Yellow Line");
    if (CheckPointer(ts) == POINTER_DYNAMIC) delete ts;
      return;
  }
  if(ts.side=="Long") {
    priceLevel = iLow(NULL,0,offset);
    Print("***** "+ts.setupType+" priceLevel="+priceLevel+" ylLevel="+ts.yellowLineLevel+"  side="+ts.side);
    if(priceLevel > ts.yellowLineLevel) submit = true;
    action = OP_BUYLIMIT;
  }
  else if(ts.side=="Short") {
    priceLevel = iHigh(NULL,0,offset);
    Print("***** "+ts.setupType+" priceLevel="+priceLevel+" ylLevel="+ts.yellowLineLevel+"  side="+ts.side);
    if(priceLevel < ts.yellowLineLevel) submit = true;
    action = OP_SELLLIMIT;
  }
  else {
    Warn("Side not recognized: "+ts.side+__FUNCTION__);
  }
  if(submit) {
    ClosePendingLimitOrders(Symbol());
    CreatePendingLimitOrder(account, broker, priceLevel, action);
  }
  //SetTradeTypeObj("CDM");
  if (CheckPointer(ts) == POINTER_DYNAMIC) delete ts;
}

void cdmLong(Account *account, Broker *broker, int offset=1) {
  double priceLevel = iLow(NULL,0,offset);
  TradeStatus *ts;
  ts = new TradeStatus();
  ts.SetSetup("CDM","Long",string(priceLevel));
  PlotYellowLine(priceLevel);
  ClosePendingLimitOrders(Symbol());
  CreatePendingLimitOrder(account, broker, priceLevel, OP_BUYLIMIT);
  //SetTradeTypeObj("CDM");
  if (CheckPointer(ts) == POINTER_DYNAMIC) delete ts;
}

void cdmShort(Account *account, Broker *broker, int offset=1) {
  double priceLevel = iHigh(NULL,0,offset);
  TradeStatus *ts;
  ts = new TradeStatus();
  ts.SetSetup("CDM","Short",string(priceLevel));
  PlotYellowLine(priceLevel);
  ClosePendingLimitOrders(Symbol());
  CreatePendingLimitOrder(account, broker, priceLevel, OP_SELLLIMIT);
  //SetTradeTypeObj("CDM");
  if (CheckPointer(ts) == POINTER_DYNAMIC) delete ts;
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

void CreatePendingLimitOrder(Account *account, 
                             Broker *broker, 
                             double limitPrice, int operation, bool allowForSpread=false, int margin=0, int spread=0) {
  MagicNumber *magic = new MagicNumber();
  string normalizedSymbol = broker.NormalizeSymbol(Symbol());
  Position * trade = new Position();
  int oneR = LookupStopPips(normalizedSymbol);
  double stopLoss =  oneR * OnePoint;
  trade.LotSize = CalcTradeSize(account,stopLoss);
  trade.IsPending = true;
  trade.OpenPrice = limitPrice;
  trade.OrderType = operation;
  trade.Symbol = broker.NormalizeSymbol(Symbol());
  trade.Reference = __FILE__;
  trade.Magic = magic.get("CDM",oneR);
  Debug("=====>Trade.magic="+trade.Magic);
  //SetTradeTypeObj("CMD");
  broker.CreateOrder(trade);
  if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
  if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
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
