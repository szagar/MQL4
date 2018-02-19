//+------------------------------------------------------------------+
//|                                                          Rsi.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_rsi_01 = ""; //---------------------------------------------
extern string commentString_rsi1 = ""; //*** RSI settings:
extern Enum_RSI_MODELS RSI_Model = RSI_SETUP_01; //>> RSI Model
extern int RSI_period = 21;          //- RSI period
extern double RSI_upperLevel = 70.0; //- upper trigger level
extern double RSI_lowerLevel = 30.0; //- lower trigger level
extern int RSI_bars2expiry;          //- #bars setup trigger active

#include <dev\common.mqh>
#include <dev\SetupBase.mqh>
  
class Rsi : public SetupBase {

  int crossUpUpper;
  int crossDnUpper;
  int crossUpLower;
  int crossDnLower;
  void reset();

  void levelPiercing();
  bool longCriteria();
  bool shortCriteria();
  void triggerUpperLevelPiercing();
  void triggerLowerLevelPiercing();
 
public:
  Rsi(string, Enum_SIDE);
  ~Rsi();
  void startOfDay();
  void OnBar();
  void OnTick();
};

Rsi::Rsi(string _symbol, Enum_SIDE _side):SetupBase(_symbol,_side) {
  strategyName = "RSI";
  symbol = _symbol;
  side = _side;
  callOnTick = false;
  callOnBar = true;
}


Rsi::~Rsi() {
}

void Rsi::startOfDay() {
  reset();
}

void Rsi::reset() {
  SetupBase::reset();
  crossUpUpper = 0;
  crossDnUpper = 0;
  crossUpLower = 0;
  crossDnLower = 0;
}

void Rsi::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  levelPiercing();
  if(GoLong) triggered = longCriteria();
  if(GoShort) triggered = shortCriteria();
}

void Rsi::OnTick() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

void Rsi::levelPiercing() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  static double prevRSI=0;

  double rsi0=iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,1);
  double rsi1=prevRSI;  //iRSI(Symbol(),0,RSI_period,PRICE_CLOSE,2);
  Debug(__FUNCTION__,__LINE__,"  rsi0("+RSI_period+")="+rsi0+"   rsi1="+rsi1+" "+prevRSI+"     "+RSI_upperLevel+" / "+RSI_lowerLevel);
  if(rsi0>RSI_upperLevel && rsi1<RSI_upperLevel) {
    crossUpUpper = dayBarNumber;
    triggerUpperLevelPiercing();
  }
  if(rsi0<RSI_upperLevel && rsi1>RSI_upperLevel) {
    crossDnUpper = dayBarNumber;
    triggerUpperLevelPiercing();
  }
  if(rsi0>RSI_lowerLevel && rsi1<RSI_lowerLevel) {
    crossUpLower = dayBarNumber;
    triggerLowerLevelPiercing();
  }
  if(rsi0<RSI_lowerLevel && rsi1>RSI_lowerLevel) {
    crossDnLower = dayBarNumber;
    triggerLowerLevelPiercing();
  }
  Debug(__FUNCTION__,__LINE__,crossUpUpper+" - "+crossDnUpper+" - "+crossUpLower+" - "+crossDnLower);
  prevRSI = rsi0;
}

void Rsi::triggerUpperLevelPiercing() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  static int upObjCnt=0;
  string objname;
  objname = "RsiUpper_"+IntegerToString(upObjCnt++);
  Comment("Draw Object: ",objname);
  ObjectCreate(objname,OBJ_ARROW,0,Time[1],High[1]);
  ObjectSet(objname,OBJPROP_ARROWCODE,SYMBOL_ARROWDOWN);
  ObjectSetInteger(0,objname,OBJPROP_COLOR,clrBlack);
}

void Rsi::triggerLowerLevelPiercing() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  static int dnObjCnt=0;
  string objname;
  objname = "RsiLower_"+IntegerToString(dnObjCnt++);
  Comment("Draw Object: ",objname);
  ObjectCreate(objname,OBJ_ARROW,0,Time[1],Low[1]);
  ObjectSetInteger(0,objname,OBJPROP_COLOR,clrBlack);
}

bool Rsi::longCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  switch(RSI_Model) {
    case RSI_SETUP_01:
      if(dayBarNumber-crossUpUpper<RSI_bars2expiry) return(true);
      break;
    case RSI_SETUP_02:
      if(dayBarNumber-crossDnUpper<RSI_bars2expiry) return(true);
      break;
  }
  return(false);
}

bool Rsi::shortCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  switch(RSI_Model) {
    case RSI_SETUP_01:
      if(dayBarNumber-crossDnLower<RSI_bars2expiry) return(true);
      break;
    case RSI_SETUP_02:
      if(dayBarNumber-crossUpLower<RSI_bars2expiry) return(true);
      break;
  }
  return(false);
}

