//+------------------------------------------------------------------+
//|                                               BollingerBand.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev\common.mqh>
#include <dev\SetupBase.mqh>
  
extern string commentString_BB_01 = ""; //---------------------------------------------
extern string commentString_BB_02 = "";  //*** Bollinger Bands setup:
extern Enum_BOLLINGER_MODELS BB_Model = BB_SETUP_01; //>> Bollinger Band Model
extern int BB_Period = 200;          //- Period of the Bollinger Bands
extern double BB_Deviation = 2;      //- Deviation of the Bollinger Bands
extern int BB_BarsSincePierce = 5;   //- Bars Since Pierce

class BollingerBand : public SetupBase {
//private:
  //SetupBase setupBase;
  int model;
  bool longCriteria();
  bool shortCriteria();
  int movingPeriod;
  int BB_PiercedUpper;
  int BB_PiercedLower;
  bool bullish();
  bool bearish();
  void bandPiercing();
  
public:
  BollingerBand(string,Enum_SIDE);
  ~BollingerBand();
  
  void OnTick(bool tradeWindow);
  virtual void OnTick();
  virtual void OnBar(void);
  virtual void startOfDay();

  void reset();
  void triggerUpperBandPiercing(int);
  void triggerLowerBandPiercing(int);

};


void BollingerBand::BollingerBand(string _symbol,Enum_SIDE _side):SetupBase(_symbol,_side) {
  strategyName = "BollingerBand";
  side = _side;
  triggered = false;
  callOnTick = false;
  callOnBar = true;
}

/**
void BollingerBand::BollingerBand(string _symbol):SetupBase() {
  name = "BollingerBand";
  side = Long;
  model = 1;
  movingPeriod = 100;
}

BollingerBand::BollingerBand(string _symbol, Enum_SIDE _side, int _model):SetupBase(_symbol) {
  name = "BollingerBand";
  side = _side;
  model = _model;
  movingPeriod = 100;
}

BollingerBand::BollingerBand(Enum_SIDE _side, int _model):SetupBase() {
  name = "BollingerBand";
  side = _side;
  model = _model;
  movingPeriod = 100;
}
**/

BollingerBand::~BollingerBand() {
}

void BollingerBand::reset() {
  BB_PiercedUpper = 0;
  BB_PiercedLower = 0;
  triggered = false;
}

void BollingerBand::startOfDay() {
  reset();
}

void BollingerBand::OnBar(void) {
  Debug4(__FUNCTION__,__LINE__,"Entered");
  bandPiercing();
  Debug4(__FUNCTION__,__LINE__,"BB_Model="+EnumToString(BB_Model));
  //bool pass = false;
  switch(BB_Model) {
    case BB_SETUP_01:
    case BB_SETUP_02:
      if(GoLong) triggered = longCriteria();
      if(GoShort) triggered = shortCriteria();
      break;
    default:;
      //pass = false;
  }
}

void BollingerBand::OnTick() {  
  Debug4(__FUNCTION__,__LINE__,"Entered");
}

void BollingerBand::bandPiercing() {
  Debug4(__FUNCTION__,__LINE__,"Entered");
  double topCurr=iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_UPPER,1);
  double topPrev=iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_UPPER,2);
  double lowCurr=iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_LOWER,1);
  double lowPrev=iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_LOWER,2);
  Debug(__FUNCTION__,__LINE__,"BBtop Curr="+DoubleToString(topCurr,Digits)+"  Prev="+DoubleToString(topPrev,Digits));
  Debug(__FUNCTION__,__LINE__,"BBlow Curr="+DoubleToString(lowCurr,Digits)+"  Prev="+DoubleToString(lowPrev,Digits));
  switch(BB_Model) {
    case BB_SETUP_01:
      if(Close[2]<topPrev && Close[1]>topCurr) 
        triggerUpperBandPiercing(dayBarNumber);
      if(Close[2]>lowPrev && Close[1]<lowCurr) 
        triggerLowerBandPiercing(dayBarNumber);
      break;
    case BB_SETUP_02:
      if(Close[2]>topPrev && Close[1]<topCurr) 
        triggerUpperBandPiercing(dayBarNumber);
      if(Close[2]<lowPrev && Close[1]>lowCurr) 
        triggerLowerBandPiercing(dayBarNumber);
      break;
    case BB_SETUP_03:
      break;
  }
}

void BollingerBand::triggerUpperBandPiercing(int barN) {
  Debug4(__FUNCTION__,__LINE__,"Entered");
  static int topCnt=0;
  string objname;
  BB_PiercedUpper = barN;
  objname = "PierceUp"+IntegerToString(topCnt++);
  
  Debug4(__FUNCTION__,__LINE__,"BB_Model="+EnumToString(BB_Model)+"  objname="+objname+"  at="+DoubleToStr(High[1]+5*P2D,Digits));
  ObjectCreate(objname,OBJ_ARROW,0,Time[1],High[1]);
  ObjectSet(objname, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
  ObjectSetInteger(0,objname,OBJPROP_COLOR,clrBlack);
}

void BollingerBand::triggerLowerBandPiercing(int barN) {
  Debug4(__FUNCTION__,__LINE__,"Entered");
  static int topCnt=0;
  string objname;
  BB_PiercedLower = barN;
  objname = "PierceDn"+IntegerToString(topCnt++);
  ObjectCreate(objname,OBJ_ARROW,0,Time[1],Low[1]);
  ObjectSetInteger(0,objname,OBJPROP_COLOR,clrBlack);
}

bool BollingerBand::longCriteria() {
  Debug4(__FUNCTION__,__LINE__,IntegerToString(dayBarNumber-BB_PiercedLower)+" < "+IntegerToString(BB_BarsSincePierce));
  if (BB_PiercedLower && dayBarNumber-BB_PiercedLower < BB_BarsSincePierce
    && bullish()) return true;
  return false;
}

bool BollingerBand::shortCriteria() {
  if (BB_PiercedUpper && dayBarNumber-BB_PiercedUpper < BB_BarsSincePierce
    && bearish()) return true;
  return false;
}

bool BollingerBand::bullish() {
  Debug4(__FUNCTION__,__LINE__,"BB_Model="+IntegerToString(BB_Model));
return(true);
  switch(BB_Model) {
    case BB_SETUP_01:
      if (Close[0] > Close[1]) return true;
      break;
    case BB_SETUP_02:
      if (Close[0] > Close[1]) return true;
      //if (Close[0] > Close[1] && Close[1] > Close[2]) return true;
      break;
    //case 3:
    //  if (Close[0] > iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_MAIN,0))
    //    return true;
    //  break;
    default:
      return false;
  }
  return false;
}

bool BollingerBand::bearish() {
  switch(BB_Model) {
    case BB_SETUP_01:
      if (Close[0] < Close[1]) return true;
      break;
    case BB_SETUP_02:
      if (Close[0] < Close[1]) return true;
      //if (Close[0] < Close[1] && Close[1] < Close[2]) return true;
      break;
    //case 3:
    //  if (Close[0] < iBands(Symbol(),0,BB_Period,BB_Deviation,0,PRICE_CLOSE,MODE_MAIN,0))
    //    return true;
    default:
      return false;
  }
  return false;
}
