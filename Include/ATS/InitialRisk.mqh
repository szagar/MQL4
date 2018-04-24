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
#include <ATS\zts_lib.mqh>
#include <ATS\SetupStruct.mqh>

#include <ATS\initialRisk_externs.mqh>

class InitialRisk {
private:
  string PatiExceptionPairs;
  int defaultModel;

  int calcPatiPips(string symbol);

public:
  InitialRisk();
  ~InitialRisk();
  
  int getInPips(string,Enum_SIDE,Enum_INITIAL_RISK);
  //int getInPips(Position*,Enum_INITIAL_RISK);
  //int getInPips(SetupStruct*,Enum_INITIAL_RISK);

};

InitialRisk::InitialRisk() {
  PatiExceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
}

InitialRisk::~InitialRisk() {
}

int InitialRisk::getInPips(string symbol, Enum_SIDE side, Enum_INITIAL_RISK _model=NULL) {
  if(_model == NULL) _model = OneRmodel;
  int pips=0;
  Enum_INITIAL_RISK model = (_model>0 ? _model : OneRmodel); 
  double px, sl;
  double atr;
  int val_index;
  int sidex;
  
  switch(model) {
    case IR_PATI_Pips:      // PATI static pips
      pips = calcPatiPips(symbol);
      break;
    case IR_DayATR:
      atr = calc_ATR(symbol,PERIOD_D1,IR_BarCount);
      pips = int(calc_ATR(symbol,PERIOD_D1,IR_BarCount)*PipFact*IR_ATRfactor);
      break;
    case IR_ATR:
      atr = calc_ATR(symbol,IR_AtrTF,IR_BarCount);
      pips = int(calc_ATR(symbol,IR_AtrTF,IR_BarCount)*PipFact*IR_ATRfactor);
      break;
    case IR_PrevHL:
      if(side==Short) {
        px = Close[1];   //Bid;
        sidex = -1;
        val_index=iHighest(NULL,0,MODE_HIGH,IR_BarCount+1,1);
        sl = iHigh(NULL,0,val_index);
      } else {
        px = Close[1];   //Ask;
        sidex = 1;
        val_index=iLowest(NULL,0,MODE_LOW,IR_BarCount+1,1);
        sl = iLow(NULL,0,val_index);
      }
      pips = int((px-sl)*sidex * D2P);
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
