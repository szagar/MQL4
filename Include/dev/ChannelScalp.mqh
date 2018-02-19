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
extern Enum_CS_MODELS CS_Model = CS_MovingAvg;       //a>Model
extern ENUM_MA_METHOD     CS_1_Type = MODE_SMA;     //- MA-1 type (upper)
extern ENUM_APPLIED_PRICE CS_1_Price = PRICE_HIGH; //- MA-1 price to use
extern int                CS_1_Periods = 3;         //- MA-1 #periods
extern ENUM_TIMEFRAMES    CS_1_TimeFrame = PERIOD_CURRENT; //- MA-1 timeframe
extern ENUM_MA_METHOD     CS_2_Type = MODE_SMA;            //- MA-2 type (lower)
extern ENUM_APPLIED_PRICE CS_2_Price = PRICE_LOW;        //- MA-2 price to use
extern int                CS_2_Periods = 3;                //- MA-2 #periods
extern ENUM_TIMEFRAMES    CS_2_TimeFrame = PERIOD_CURRENT; //- MA-2 timeframe
extern int                CS_EntryBufferPoints = 5;        //- Bars active
//extern int                CS_EntryBufferPoints = 5;        //- Bars active

#include <dev\common.mqh>
#include <dev\SetupBase.mqh>
  
class ChannelScalp : public SetupBase {

  int crossFastUp;
  int crossFastDn;
  int pendingLong;
  int pendingShort;
  double longPosition;
  double shortPosition;
  bool IsLong;
  bool IsShort;
  int triggerBarCnt;

  double lower, upper;
  bool UpTrend, DnTrend;
  bool NotLong, NotShort;
  void reset();

  void positionStatus();
  void getLevelsAndTrends();
  bool longCriteria();
  bool shortCriteria();
  

public:
  ChannelScalp(Enum_SIDE);
  ~ChannelScalp();
  
  //bool triggered();
  void startOfDay();
  void OnBar();
  void OnTick();
};

ChannelScalp::ChannelScalp(Enum_SIDE _side):SetupBase(Symbol(),_side) {
  strategyName = "ChannelScalp";
  side = _side;
  callOnTick = true;
  callOnBar = true;
  reset();
}


ChannelScalp::~ChannelScalp() {
}

void ChannelScalp::reset() {
  SetupBase::reset();
  crossFastUp = -100;
  crossFastDn = -100;
}

void ChannelScalp::startOfDay() {
 reset();
}

void ChannelScalp::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  triggerBarCnt = 0;
  getLevelsAndTrends();
  //if(GoLong && UpTrend && !IsLong)
  //  triggered = longCriteria();
  //else if(GoShort)
  //  triggered = shortCriteria();
  
}

void ChannelScalp::OnTick() {
  //Debug(__FUNCTION__,__LINE__,"Entered");
  if(GoLong && 
     UpTrend &&
     !IsLong &&
     triggerBarCnt == 0 &&
     Ask < lower) {
    triggered = true;
    triggerBarCnt++;
    markOnChart(Time[0],upper+5*PipSize);
    Debug(__FUNCTION__,__LINE__,"----> go long");
  }
  if(GoShort &&
     DnTrend &&
     !IsShort &&
     triggerBarCnt == 0 &&
     Bid > upper) {
    triggered = true;
    triggerBarCnt++;
    markOnChart(Time[0],lower-5*PipSize);
    Debug(__FUNCTION__,__LINE__,"----> go short");
  }
}

bool ChannelScalp::longCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  switch(CS_Model) {
    case CS_MovingAvg:
      break;
  }
  return false;
}

bool ChannelScalp::shortCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  switch(CS_Model) {
    case CS_MovingAvg:
      break;
  }
  return false;
}

void ChannelScalp::getLevelsAndTrends() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  upper = iMA(NULL,0,CS_1_Periods,0,CS_1_Type,CS_1_Price,0);
  lower = iMA(NULL,0,CS_2_Periods,0,CS_2_Type,CS_2_Price,0);
  double upperPrev = iMA(NULL,0,CS_1_Periods,0,CS_1_Type,CS_1_Price,1);
  double lowerPrev = iMA(NULL,0,CS_2_Periods,0,CS_2_Type,CS_2_Price,1);

  UpTrend =  (upper-upperPrev) > 0 ? true : false;
  DnTrend =  (lowerPrev-lower) > 0 ? true : false;

  positionStatus();
  
  string str;
  str="Upper: "+DoubleToStr(upper,Digits)+" Lower: "+DoubleToStr(lower,Digits);
  if(UpTrend) str += "  UpTrend";
  if(DnTrend) str += "  DnTrend";
  str+="\npl="+pendingLong+"  ps="+pendingShort+" long="+longPosition+" short="+shortPosition+" isLong="+IsLong+" isShort="+IsShort;

  Comment(str);
  Debug(__FUNCTION__,__LINE__,DoubleToStr(lower,Digits)+" - "+DoubleToStr(upper,Digits));
}

void ChannelScalp::positionStatus() {
  pendingLong=NULL;
  pendingShort=NULL;
  longPosition = 0;
  shortPosition = 0;
  IsLong = false;
  IsShort = false;
  int lastError=0;
  int ot;
  
  for(int i=OrdersTotal()-1; i>=0; i--)  {
    if(!OrderSelect(i,SELECT_BY_POS)) {
      lastError = GetLastError();
      Warn("OrderSelect("+string(i)+", SELECT_BY_POS) - Error #"+string(lastError));
      continue;
    }
    if(StringCompare(OrderSymbol(),Symbol())==0) {  // &&
       //magic.roboID(OrderMagicNumber()) == RoboID) {
       ot = OrderType();
      if(ot == OP_BUY ) {
        IsLong = true;
        longPosition = OrderTicket();
      }
      if(ot == OP_SELL) {
        IsShort = true;
        shortPosition = OrderTicket();
      }
      if(ot == OP_BUYLIMIT || ot == OP_BUYSTOP)
        pendingLong = OrderTicket();
      if(ot == OP_SELLLIMIT || ot == OP_SELLSTOP)
        pendingShort = OrderTicket();
    }
  }
}
