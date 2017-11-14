//+------------------------------------------------------------------+
//|                                                        SymbolSizeStopPips.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, SSTK Assoc"
#property link      "https://"
#property version   "1.00"
#property strict
#include <Position.mqh>
#include <zts/Broker.mqh>


string Prefix = "PAT_";
double AdjPoint;
Broker * broker;

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

  string normalizedSymbol = broker.NormalizeSymbol(Symbol());
  double Rpips = CalculateStop(normalizedSymbol);
  double size = CalcTradeSize(Rpips);   // *AdjPoint);
  string label_str = PairAbrevation(normalizedSymbol) + "  -  " + string(Rpips) + "  -  " + DoubleToString(size,2);
        
  string labelName = Prefix + "Legend";
  if (ObjectFind(0, labelName) == 0) ObjectDelete(0, labelName);
  ObjectCreate(labelName, OBJ_LABEL, 0, 0, 0);
  ObjectSetText(labelName,label_str,10, "Verdana", Red);
  ObjectSet(labelName, OBJPROP_CORNER, 1);
  ObjectSet(labelName, OBJPROP_XDISTANCE, 150);
  ObjectSet(labelName, OBJPROP_YDISTANCE, 10);
}

//+---------------------------------------------------------------------------+
//| The function calculates the amount, in USD, secured with stop losses in   |
//| open positions.                                                               |
//+---------------------------------------------------------------------------+
double LockedIn() {
  return(0.0);
}

//+---------------------------------------------------------------------------+
//| The function calculates the postion size based on stop loss level, risk   |
//| per trade and account balance.                                                               |
//+---------------------------------------------------------------------------+
double CalcTradeSize(double RinPips, double PercentRiskPerPosition=0.5)
{
  double dollarRisk = (AccountFreeMargin()+ LockedIn()) * PercentRiskPerPosition/100.0;

  double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
  if(Digits==3 || Digits==5) nTickValue=nTickValue*10;

  double LotSize = dollarRisk /(RinPips * nTickValue);
  LotSize=MathRound(LotSize/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);
  return(LotSize);
}

int CalculateStop(string symbol) {
  string ConfigureStops = "===Configure Stop Loss Levels===";
  int DefaultStopPips = 12;
  string ExceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
  
  int stop = DefaultStopPips;
  int pairPosition = StringFind(ExceptionPairs, symbol, 0);
  if (pairPosition >=0) {
     int slashPosition = StringFind(ExceptionPairs, "/", pairPosition) + 1;
     stop = int(StringToInteger(StringSubstr(ExceptionPairs,slashPosition)));
  }
  return stop;
}

string PairAbrevation(string pair) {
  string lookup = ";EURUSD/EU;AUDUSD/AU;AUDJPY/AJ;CADJPY/CJ;GBPJPY/GJ;GBPUSD/GU;EURJPY/EJ;USDJPY/UJ;USDCAD/CAD;USDCHF/CHF;NZDUSD/NU";
  string rtn = "DNK";
  int pos = StringFind(lookup, pair, 0);
  if (pos > 0) {
    int slashPosition = StringFind(lookup, "/", pos) + 1;
    int endPosition = StringFind(lookup, ";", slashPosition);
    rtn = StringSubstr(lookup, slashPosition,endPosition-slashPosition);
  }
  return rtn;
}