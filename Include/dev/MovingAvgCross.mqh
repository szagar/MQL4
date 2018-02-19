//+------------------------------------------------------------------+
//|                                               MovingAvgCross.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_MX_01 = ""; //---------------------------------------------
extern string commentString_MX_22 = "";  //*** Moving Average Cross setting:
extern Enum_MX_MODELS MX_Model = MX_SETUP_01;       //a>Model
extern ENUM_MA_METHOD     MX_1_Type = MODE_SMMA;    //- MA-1 type (fast)
extern ENUM_APPLIED_PRICE MX_1_Price = PRICE_CLOSE; //- MA-1 price to use
extern int                MX_1_Periods = 5;         //- MA-1 #periods
extern ENUM_TIMEFRAMES    MX_1_TimeFrame = PERIOD_CURRENT; //- MA-1 timeframe
extern ENUM_MA_METHOD     MX_2_Type = MODE_EMA;            //- MA-2 type (slow)
extern ENUM_APPLIED_PRICE MX_2_Price = PRICE_CLOSE;        //- MA-2 price to use
extern int                MX_2_Periods = 21;               //- MA-2 #periods
extern ENUM_TIMEFRAMES    MX_2_TimeFrame = PERIOD_CURRENT; //- MA-2 timeframe
extern int                MX_BarsSetupActive = 5;          //- Bars active

#include <dev\common.mqh>
#include <dev\SetupBase.mqh>
  
class MovingAvgCross : public SetupBase {

  int crossFastUp;
  int crossFastDn;
  void reset();

  void check4crossing();
  bool longCriteria();
  bool shortCriteria();
  

public:
  MovingAvgCross(Enum_SIDE);
  ~MovingAvgCross();
  
  //bool triggered();
  void startOfDay();
  void OnBar();
  void OnTick();
};

MovingAvgCross::MovingAvgCross(Enum_SIDE _side):SetupBase(Symbol(),_side) {
  strategyName = "MovingAvgCross";
  side = _side;
  callOnTick = false;
  callOnBar = true;
  reset();
}


MovingAvgCross::~MovingAvgCross() {
}

void MovingAvgCross::reset() {
  SetupBase::reset();
  crossFastUp = -100;
  crossFastDn = -100;
}

void MovingAvgCross::startOfDay() {
 reset();
}

void MovingAvgCross::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  check4crossing();
  //if(GoLong) triggered = longCriteria();
  //if(GoShort) triggered = shortCriteria();
  if(GoLong)
    triggered = longCriteria();
  else if(GoShort)
    triggered = shortCriteria();
  
}

void MovingAvgCross::OnTick() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

//bool MovingAvgCross::triggered(void) {
//  Debug(__FUNCTION__,__LINE__,"Entered");
//  bool pass = false;
//  switch(MX_Model) {
//    case MX_SETUP_01:
//      if(side==Long) pass = longCriteria();
//      if(side==Short) pass = shortCriteria();
//      break;
//    default:
//      pass = false;
//  }
//  return pass;
//}

bool MovingAvgCross::longCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  switch(MX_Model) {
    case MX_SETUP_01:
      Debug(__FUNCTION__,__LINE__,": "+barNumber+" - "+crossFastUp+" < "+MX_BarsSetupActive);
      Info(__FUNCTION__+": "+barNumber+" - "+crossFastUp+" < "+MX_BarsSetupActive);
      if((barNumber-crossFastUp) < MX_BarsSetupActive && 
         Close[1] > Open[1]) return true;
      break;
    case MX_SETUP_02:
      if((barNumber-crossFastDn) < MX_BarsSetupActive &&
         Close[1] > Open[1]) return true;
      break;
  }
  return false;
}

bool MovingAvgCross::shortCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  switch(MX_Model) {
    case MX_SETUP_01:
      Debug(__FUNCTION__,__LINE__,": "+barNumber+" - "+crossFastDn+" < "+MX_BarsSetupActive);
      Info(__FUNCTION__+": "+barNumber+" - "+crossFastDn+" < "+MX_BarsSetupActive);
      if((barNumber-crossFastDn) < MX_BarsSetupActive &&
         Close[1] < Open[1]) return true;
      break;
    case MX_SETUP_02:
      if((barNumber-crossFastUp) < MX_BarsSetupActive && 
         Close[1] < Open[1]) return true;
      break;
      break;
  }
  return false;
}

void MovingAvgCross::check4crossing() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  Debug(__FUNCTION__,__LINE__,"smz: "+barNumber+"  Up="+crossFastUp+"  DN="+crossFastDn);
  double PreviousFast = iMA(NULL,0,MX_1_Periods,0,MX_1_Type,MX_1_Price,2);
  double CurrentFast  = iMA(NULL,0,MX_1_Periods,0,MX_1_Type,MX_1_Price,1);
  double PreviousSlow = iMA(NULL,0,MX_2_Periods,0,MX_2_Type,MX_2_Price,2);
  double CurrentSlow  = iMA(NULL,0,MX_2_Periods,0,MX_2_Type,MX_2_Price,1);

  Debug(__FUNCTION__,__LINE__,DoubleToStr(PreviousFast,Digits)+" - "+DoubleToStr(PreviousSlow,Digits)+" - "+DoubleToStr(CurrentFast,Digits)+" - "+DoubleToStr(CurrentSlow,Digits));
  if(PreviousFast<PreviousSlow && CurrentFast>CurrentSlow) {
    crossFastUp = barNumber;
    Info("crossFastUp="+crossFastUp);
    markOnChart(Time[1],CurrentSlow+5*PipSize);
  }
  if(PreviousFast>PreviousSlow && CurrentFast<CurrentSlow) {
    crossFastDn = barNumber; 
    Info("crossFastDn="+crossFastDn);
    markOnChart(Time[1],CurrentSlow+5*PipSize);
  }
}

