//+------------------------------------------------------------------+
//|                                               MovingAvgCross.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_22 = "";  //*****************************************
extern string commentString_23 = "";  //Setup: Moving Average Cross Settings
extern Enum_MX_MODELS MX_Model = MX_SETUP_01;             //> Model
extern ENUM_MA_METHOD MA_1_Type = MODE_SMA;           //> MA-1 type
extern ENUM_APPLIED_PRICE MA_1_PRICE = PRICE_CLOSE;   //> MA-1 price to use
extern int MX_1_Periods = 5;                          //> MA-1 #periods
extern ENUM_TIMEFRAMES MX_1_TimeFrame = Current;      //> MA-1 timeframe
extern ENUM_MA_METHOD MX_2_Type = MODE_SMA;           //> MA-2 type
extern ENUM_APPLIED_PRICE MA_2_PRICE = PRICE_CLOSE;   //> MA-2 price to use
extern int MX_2_Periods = 21;                         //> MA-2 #periods
extern ENUM_TIMEFRAMES MX_2_TimeFrame = current;      //> MA-2 timeframe

#include <dev\common.mqh>
#include <dev\Setup.mqh>
  
class MovingAvgCross : public Setup {

  int crossFastUp;
  int crossFastDn;
  void reset();

  bool longCriteria();
  bool shortCriteria();

public:
  MovingAvgCross(Enum_SIDE);
  ~MovingAvgCross();
  
  bool triggered();
};

MovingAvgCross::MovingAvgCross(Enum_SIDE _side):Setup(Symbol(),_side) {
  strategyName = "MovingAvgCross";
  side = _side;
  movingPeriod = 100;
  model = MX_Model;
}


MovingAvgCross::~MovingAvgCross() {
}

void MovingAvgCross::reset() {
  crossFastUp = 0;
  crossFastDn = 0;
  triggered = false;
}

void MovingAvgCross::startOfDay() {
 reset();
}

void MovingAvgCross::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  check4crossing();
}

bool MovingAvgCross::triggered(void) {
  bool pass = false;
  switch(model) {
    case 1:
      if(side==Long) pass = longCriteria();
      if(side==Short) pass = shortCriteria();
      break;
    default:
      pass = false;
  }
  return pass;
}

bool MovingAvgCross::longCriteria() {
  double ma;

  //---- go trading only for first tiks of new bar
  if(Volume[0]>1) return false;
  //---- get Moving Average 
  ma=iMA(NULL,0,movingPeriod,0,MODE_SMA,PRICE_CLOSE,0); 
  //---- buy conditions
  if(Open[1]<ma && Close[1]>ma) return false;
  if(Open[2]>ma && Close[2]>ma) {
    //res=OrderSend(Symbol(),OP_BUY,GetLots(),Ask,3,0,0,"",BRO,0,Blue);
    return true;
  }
  return false;
}

bool MovingAvgCross::shortCriteria() {
  double ma;

  //---- go trading only for first tiks of new bar
  if(Volume[0]>1) return false;
  //---- get Moving Average 
  ma=iMA(NULL,0,movingPeriod,0,MODE_SMA,PRICE_CLOSE,0); 
  //---- sell conditions
  if(Open[1]>ma && Close[1]<ma) return false;
  if(Open[2]<ma && Close[2]<ma) {
    //res=OrderSend(Symbol(),OP_SELL, GetLots(),Bid,3,0,0,"",BROV,0,Red);
    return true;
  }
  return false;
}

void MovingAvgCross::check4crossing() {
}
