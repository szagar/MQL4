//+------------------------------------------------------------------+
//|                                                         InitialRisk.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

//#include <zts\Account.mqh>
#include <dev\zts_lib.mqh>
#include <dev\SetupStruct.mqh>

enum Enum_INITIAL_RISK { IR_PATI_Pips, IR_ATR, IR_PrevHL};

extern string commentString_IR_1 = ""; //---------------------------------------------
extern string commentString_IR_2 = ""; //--------- Initial Risk (1R) settings 
extern string commentString_IR_3 = ""; //---------------------------------------------
extern Enum_INITIAL_RISK OneRmodel = IR_ATR;  //>> 1R model
extern int IR_BarCount = 3;                   //-    BarCount
extern ENUM_TIMEFRAMES IR_ATRperiod = 0;      //-    ATR period
extern double IR_ATRfactor = 2.7;             //-    ATR multiplier

class InitialRisk {
private:
  string PatiExceptionPairs;
  int defaultModel;

  int calcPatiPips(string symbol);

public:
  InitialRisk();
  ~InitialRisk();
  
  int getInPips(Position*,Enum_INITIAL_RISK);
  int getInPips(SetupStruct*,Enum_INITIAL_RISK);

};

InitialRisk::InitialRisk() {
  PatiExceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
}

InitialRisk::~InitialRisk() {
}

int InitialRisk::getInPips(SetupStruct *setup, Enum_INITIAL_RISK _model=NULL) {
  if(_model == NULL) _model = OneRmodel;
  Debug(__FUNCTION__,__LINE__,"int InitialRisk::getInPips( "+EnumToString(_model)+", "+setup.symbol+")");
  int pips=0;
  Enum_INITIAL_RISK model = (_model>0 ? _model : OneRmodel); 
  double px, sl;
  double atr;
  int val_index;
  
  switch(model) {
    case IR_PATI_Pips:      // PATI static pips
      pips = calcPatiPips(setup.symbol);
      Debug(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips));
      break;
    case IR_ATR:
      atr = calc_ATR(setup.symbol,IR_ATRperiod,IR_BarCount);
      Info2(__FUNCTION__,__LINE__,"atr="+DoubleToStr(atr,2));
      //pips = int(oneR_calc_ATR(ATRperiod,ATRnumBars)*decimal2points_factor(symbol)*IR_ATRfactor);
      Info2(__FUNCTION__,__LINE__,"PipFact="+string(PipFact));
      Info2(__FUNCTION__,__LINE__,"IR_ATRfactor="+string(IR_ATRfactor));
      pips = int(calc_ATR(setup.symbol,IR_ATRperiod,IR_BarCount)*PipFact*IR_ATRfactor);
      Info2(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips)+"  atr="+DoubleToStr(atr,Digits));
      break;
    case IR_PrevHL:
      if(setup.side==Long) {
        px = Bid;
        val_index=iHighest(NULL,0,MODE_HIGH,IR_BarCount+1,1);
        sl = iHigh(NULL,0,val_index);
      } else {
        px = Ask;
        val_index=iLowest(NULL,0,MODE_LOW,IR_BarCount+1,1);
        sl = iLow(NULL,0,val_index);
      }
      pips = int((px-sl)*setup.side * PipFact);
      Debug(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips));
      break;
    default:
      pips = 0;
      Debug(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+DoubleToStr(pips,Digits));
  }
  return(pips);
}

int InitialRisk::getInPips(Position *trade, Enum_INITIAL_RISK _model=NULL) {
  if(_model == NULL) _model = OneRmodel;
  Debug(__FUNCTION__,__LINE__,"int InitialRisk::getInPips( "+EnumToString(_model)+", "+trade.Symbol+")");
  int pips=0;
  Enum_INITIAL_RISK model = (_model>0 ? _model : OneRmodel); 
  double px, sl;
  double atr;
  int val_index;
  
  switch(model) {
    case IR_PATI_Pips:      // PATI static pips
      pips = calcPatiPips(trade.Symbol);
      Debug(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips));
      break;
    case IR_ATR:
      atr = calc_ATR(trade.Symbol,IR_ATRperiod,IR_BarCount);
      Info2(__FUNCTION__,__LINE__,"atr="+DoubleToStr(atr,2));
      //pips = int(oneR_calc_ATR(ATRperiod,ATRnumBars)*decimal2points_factor(symbol)*IR_ATRfactor);
      Info2(__FUNCTION__,__LINE__,"PipFact="+string(PipFact));
      Info2(__FUNCTION__,__LINE__,"IR_ATRfactor="+string(IR_ATRfactor));
      pips = int(calc_ATR(trade.Symbol,IR_ATRperiod,IR_BarCount)*PipFact*IR_ATRfactor);
      Info2(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips)+"  atr="+DoubleToStr(atr,Digits));
      break;
    case IR_PrevHL:
      if(trade.Side==Long) {
        px = Bid;
        val_index=iHighest(NULL,0,MODE_HIGH,IR_BarCount+1,1);
        sl = iHigh(NULL,0,val_index);
      } else {
        px = Ask;
        val_index=iLowest(NULL,0,MODE_LOW,IR_BarCount+1,1);
        sl = iLow(NULL,0,val_index);
      }
      pips = int((px-sl)*trade.Side * PipFact);
      Debug(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+IntegerToString(pips));
      break;
    default:
      pips = 0;
      Debug(__FUNCTION__,__LINE__,"model="+EnumToString(model)+"  pips="+DoubleToStr(pips,Digits));
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
  Debug(__FUNCTION__,__LINE__,"stop="+DoubleToStr(stop,Digits));
  return stop;
}

class RiskManagement {
private:

public:

};
