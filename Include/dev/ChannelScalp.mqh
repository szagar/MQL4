//+------------------------------------------------------------------+
//|                                                 ChannelScalp.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_CS_01 = ""; //---------------------------------------------
extern string commentString_CS_22 = "";  //*** Channel Scalp setting:
extern Enum_CS_MODELS CS_Model = CS_SETUP_01;       //a>Model
extern ENUM_MA_METHOD     CS_1_Type = MODE_SMA;     //- MA-1 type (upper)
extern ENUM_APPLIED_PRICE CS_1_Price = PRICE_HIGH; //- MA-1 price to use
extern int                CS_1_Periods = 3;         //- MA-1 #periods
extern ENUM_TIMEFRAMES    CS_1_TimeFrame = PERIOD_CURRENT; //- MA-1 timeframe
extern ENUM_MA_METHOD     CS_2_Type = MODE_SMA;            //- MA-2 type (lower)
extern ENUM_APPLIED_PRICE CS_2_Price = PRICE_LOW;        //- MA-2 price to use
extern int                CS_2_Periods = 3;                //- MA-2 #periods
extern ENUM_TIMEFRAMES    CS_2_TimeFrame = PERIOD_CURRENT; //- MA-2 timeframe
extern int                CS_EntryBufferPoints = 5;        //- Bars active
extern int                CS_EntryBufferPoints = 5;        //- Bars active

#include <dev\common.mqh>
#include <dev\Setup.mqh>
  
class MovingAvgChannel : public Setup {

  int crossFastUp;
  int crossFastDn;
  void reset();

  void check4crossing();
  bool longCriteria();
  bool shortCriteria();
  

public:
  MovingAvgChannel(Enum_SIDE);
  ~MovingAvgChannel();
  
  //bool triggered();
  void startOfDay();
  void OnBar();
  void OnTick();
};

MovingAvgChannel::MovingAvgChannel(Enum_SIDE _side):Setup(Symbol(),_side) {
  strategyName = "MovingAvgChannel";
  side = _side;
  callOnTick = false;
  callOnBar = true;
  reset();
}


MovingAvgChannel::~MovingAvgChannel() {
}

void MovingAvgChannel::reset() {
  Setup::reset();
  crossFastUp = -100;
  crossFastDn = -100;
}

void MovingAvgChannel::startOfDay() {
 reset();
}

void MovingAvgChannel::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  check4crossing();
  //if(GoLong) triggered = longCriteria();
  //if(GoShort) triggered = shortCriteria();
  if(GoLong)
    triggered = longCriteria();
  else if(GoShort)
    triggered = shortCriteria();
  
}

void MovingAvgChannel::OnTick() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

bool MovingAvgChannel::longCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  switch(CS_Model) {
    case CS_SETUP_01:
      Debug(__FUNCTION__,__LINE__,": "+barNumber+" - "+crossFastUp+" < "+CS_BarsSetupActive);
      Info(__FUNCTION__+": "+barNumber+" - "+crossFastUp+" < "+CS_BarsSetupActive);
      if((barNumber-crossFastUp) < CS_BarsSetupActive && 
         Close[1] > Open[1]) return true;
      break;
    case CS_SETUP_02:
      if((barNumber-crossFastDn) < CS_BarsSetupActive &&
         Close[1] > Open[1]) return true;
      break;
  }
  return false;
}

bool MovingAvgChannel::shortCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  switch(CS_Model) {
    case CS_SETUP_01:
      Debug(__FUNCTION__,__LINE__,": "+barNumber+" - "+crossFastDn+" < "+CS_BarsSetupActive);
      Info(__FUNCTION__+": "+barNumber+" - "+crossFastDn+" < "+CS_BarsSetupActive);
      if((barNumber-crossFastDn) < CS_BarsSetupActive &&
         Close[1] < Open[1]) return true;
      break;
    case CS_SETUP_02:
      if((barNumber-crossFastUp) < CS_BarsSetupActive && 
         Close[1] < Open[1]) return true;
      break;
      break;
  }
  return false;
}

void MovingAvgChannel::check4crossing() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  Debug(__FUNCTION__,__LINE__,"smz: "+barNumber+"  Up="+crossFastUp+"  DN="+crossFastDn);
  double upper = iMA(NULL,0,CS_1_Periods,0,CS_1_Type,CS_1_Price,1);
  double lower  = iMA(NULL,0,CS_2_Periods,0,CS_2_Type,CS_2_Price,1);

  Debug(__FUNCTION__,__LINE__,DoubleToStr(lower,Digits)+" - "+DoubleToStr(upper,Digits));
}

