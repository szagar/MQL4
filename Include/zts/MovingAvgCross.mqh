//+------------------------------------------------------------------+
//|                                               MovingAvgCross.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\common.mqh>
#include <zts\Setup.mqh>
  
class MovingAvgCross : public Setup {
//private:
  //Setup setupBase;
  int model;
  bool longCriteria();
  bool shortCriteria();
  int movingPeriod;
public:
// CBar(): m_member(_Symbol), CFoo("CBAR") {Print(__FUNCTION__);}
  MovingAvgCross():Setup() {};
  MovingAvgCross(string);
  MovingAvgCross(string,Enum_SIDE,int);
  MovingAvgCross(Enum_SIDE,int); // : setupBase(_symbol);
  ~MovingAvgCross();
  
  bool triggered();
};

void MovingAvgCross::MovingAvgCross(string _symbol):Setup() {
  name = "MovingAvgCross";
  side = Long;
  model = 1;
  movingPeriod = 100;
}

MovingAvgCross::MovingAvgCross(string _symbol, Enum_SIDE _side, int _model):Setup(_symbol) {
  name = "MovingAvgCross";
  side = _side;
  model = _model;
  movingPeriod = 100;
}

MovingAvgCross::MovingAvgCross(Enum_SIDE _side, int _model):Setup() {
  name = "MovingAvgCross";
  side = _side;
  model = _model;
  movingPeriod = 100;
}


MovingAvgCross::~MovingAvgCross() {
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