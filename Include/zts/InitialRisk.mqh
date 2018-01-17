//+------------------------------------------------------------------+
//|                                                         InitialRisk.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\Account.mqh>
#include <zts\zts_lib.mqh>

enum Enum_INITIAL_RISK { IR_Pati_Pips, IR_ATR, IR_PrevHL};

extern string commentString_13 = "*****************************************";
extern string commentString_14 = "1R - INITIAL RISK SETTINGS";
extern Enum_INITIAL_RISK OneRmodel = IR_ATR;
extern int IR_BarCount = 3;
extern ENUM_TIMEFRAMES IR_ATRperiod = 0;
extern double IR_ATRfactor = 2.7;
extern string commentString_15 = "*****************************************";

class InitialRisk {
private:
  string PatiExceptionPairs;
  int defaultModel;

  int calcPatiPips(string symbol);

public:
  InitialRisk();
  ~InitialRisk();
  
  int getInPips(Position*,Enum_INITIAL_RISK);

};

InitialRisk::InitialRisk() {
  PatiExceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
}

InitialRisk::~InitialRisk() {
}

int InitialRisk::getInPips(Position *trade, Enum_INITIAL_RISK _model=NULL) {
  if(_model == NULL) _model = OneRmodel;
  Debug4(__FUNCTION__,__LINE__,"int InitialRisk::getInPips( "+EnumToString(_model)+", "+trade.Symbol+")");
  int pips=0;
  Enum_INITIAL_RISK model = (_model>0 ? _model : OneRmodel); 
  double px, sl;
  double atr;
  
  switch(model) {
    case IR_Pati_Pips:      // PATI static pips
      pips = calcPatiPips(trade.Symbol);
      Debug4(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips));
      break;
    case IR_ATR:
      atr = calc_ATR(trade.Symbol,IR_ATRperiod,IR_BarCount);
      //pips = int(oneR_calc_ATR(ATRperiod,ATRnumBars)*decimal2points_factor(symbol)*IR_ATRfactor);
      pips = int(calc_ATR(trade.Symbol,IR_ATRperiod,IR_BarCount)*decimal2points_factor(trade.Symbol)*IR_ATRfactor);
      Debug4(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips)+"  atr="+DoubleToStr(atr,Digits));
      break;
    case IR_PrevHL:
      px = (trade.Side==Long ? Bid : Ask);
      sl = (trade.Side==Long ? iLow(NULL,0,IR_BarCount) : iHigh(NULL,0,IR_BarCount));
      pips = int((px-sl)*trade.Side * decimal2points_factor(trade.Symbol));
      Debug4(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips));
      break;
    default:
      pips = 0;
      Debug4(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+DoubleToStr(pips,Digits));
  }
  return(pips);
}

int InitialRisk::calcPatiPips(string symbol) {
  int defaultStopPips = 12;
  
  int stop = defaultStopPips;
  //Debug3(__FUNCTION__+"("+__LINE__+"): PatiExceptionPairs="+PatiExceptionPairs);
  int pairPosition = StringFind(PatiExceptionPairs, symbol, 0);
  //Debug3(__FUNCTION__+"("+__LINE__+"): pairPosition="+pairPosition);
  if (pairPosition >=0) {
    int slashPosition = StringFind(PatiExceptionPairs, "/", pairPosition) + 1;
    //Debug3(__FUNCTION__+"("+__LINE__+"): slashPosition="+slashPosition);
    stop =int( StringToInteger(StringSubstr(PatiExceptionPairs,slashPosition)));
  //Debug3(__FUNCTION__+"("+__LINE__+"): stop="+stop);
  }
  Debug4(__FUNCTION__,__LINE__,"stop="+DoubleToStr(stop,Digits));
  return stop;
}

class RiskManagement {
private:

public:

};
