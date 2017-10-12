//+------------------------------------------------------------------+
//|                                                        YLbuy.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, SSTK Assoc"
#property link      "https://"
#property version   "1.00"
#property strict
//#include <stdlib.mqh>
//#include <stderror.mqh>
#include <Position.mqh>
#include <Broker.mqh>
//#include <errordescription.mqh>
#include <zts\oneR.mqh>

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
  cdmLong();
}

void cdmLong() {
  double priceLevel = iLow(NULL,0,1);
  PlotYellowLine(priceLevel);
  CreatePendingLimitOrder(priceLevel, OP_BUYLIMIT);
}


void PlotYellowLine(double priceLevel, int barShift = 1) {
  datetime ylTime = iTime(NULL, 0,barShift);
  int timeOffset = 15*60;
  PlotHorizontalSegment(ylTime - timeOffset, ylTime + timeOffset, priceLevel, Yellow);

}

void PlotHorizontalSegment(datetime timeStart, datetime timeEnd, double priceLevel, color lineColor = Red)
{
  string trendlineName = Prefix + "YellowLine";
//   ObjectSetInteger(0, rngButtonName, OBJPROP_STATE, true);
//   datetime TimeCopy[];
//   ArrayCopy(TimeCopy, Time, 0, 0, WHOLE_ARRAY);
//   double HighPrices[];
//   ArrayCopy(HighPrices, High, 0, 0, WHOLE_ARRAY);
//   double LowPrices[];
//   ArrayCopy(LowPrices, Low, 0, 0, WHOLE_ARRAY);
//   FindDayMinMax(beginningOfDay, TimeCopy[0], TimeCopy, HighPrices, LowPrices);
//   if (ObjectFind(0, Prefix + "_DayRangeHigh") == 0)
//    ObjectDelete(0, Prefix + "_DayRangeHigh");
   if (ObjectFind(0, trendlineName) == 0) ObjectDelete(0, trendlineName);
//   if (ObjectFind(0, Prefix + "_DayHighArrow") == 0) ObjectDelete(0, Prefix + "_DayHighArrow");
//   if (ObjectFind(0, Prefix + "_DayLowArrow") == 0) ObjectDelete(0, Prefix + "_DayLowArrow");
//   ObjectCreate(0, Prefix + "_DayRangeHigh", OBJ_TREND, 0, dayHiTime, dayHi, beginningOfDay + 19*60*60, dayHi);
//   ObjectSetInteger(0, Prefix + "_DayRangeHigh", OBJPROP_COLOR, _tradeLineColor);
//   ObjectSet(Prefix + "_DayRangeHigh", OBJPROP_RAY, false);
//   ObjectCreate(0, Prefix + "_DayHighArrow", OBJ_ARROW_RIGHT_PRICE, 0, beginningOfDay + 19 * 60 *60 +15*60, dayHi);
//   ObjectSetInteger(0, Prefix + "_DayHighArrow", OBJPROP_COLOR, Blue);
   ObjectCreate(0, trendlineName, OBJ_TREND, 0, timeStart, priceLevel, timeEnd, priceLevel);
   ObjectSetInteger(0, trendlineName, OBJPROP_COLOR, lineColor);
   ObjectSet(trendlineName, OBJPROP_RAY, false);
//   ObjectCreate(0, Prefix + "_DayLowArrow", OBJ_ARROW_RIGHT_PRICE, 0, beginningOfDay + 19 * 60 *60 +15*60, dayLo);
//   ObjectSetInteger(0, Prefix + "_DayLowArrow", OBJPROP_COLOR, Blue);
//   int spread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
//   CreatePendingOrdersForRange(dayHi, OP_BUYSTOP, _setPendingOrdersOnRanges, _accountForSpreadOnPendingBuyOrders, _marginForPendingRangeOrders, spread);
//   CreatePendingOrdersForRange(dayLo, OP_SELLSTOP, _setPendingOrdersOnRanges, _accountForSpreadOnPendingBuyOrders, _marginForPendingRangeOrders, spread);
//   ObjectSetInteger(0, rngButtonName, OBJPROP_STATE,false);  
}

void CreatePendingLimitOrder( double limitPrice, int operation, bool allowForSpread=false, int margin=0, int spread=0) {
  string normalizedSymbol = broker.NormalizeSymbol(Symbol());
  Position * trade = new Position();
  trade.IsPending = true;
  trade.OpenPrice = limitPrice;
  trade.OrderType = operation;
  trade.Symbol = broker.NormalizeSymbol(Symbol());
  
  stopLoss = LookupStopPips(normalizedSymbol) * AdjPoint;
  trade.LotSize = CalcTradeSize();
  
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

  double dollarRisk = (AccountFreeMargin()+ LockedIn()) * PercentRiskPerPosition/100.0;

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

