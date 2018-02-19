//+------------------------------------------------------------------+
//|                                                     RboSetup.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_RB0 = ""; //---------------------------------------------
extern string commentString_RB1 = ""; //--------- Range BreakOut setup
extern string commentString_RB2 = ""; //---------------------------------------------
extern bool UseDefaultParameters = true; // Use pre-configured parameters for pattern

#include <dev\common.mqh>
#include <dev\candle_patterns.mqh>
#include <dev\SetupBase.mqh>
#include <dev\zts_lib.mqh>

class RboSetup : public SetupBase {

  void reset();
  void defaultParameters();

  void criteriaData();
  bool longCriteria();
  bool shortCriteria();
  
public:
  RboSetup(Enum_SIDE);
  ~RboSetup();
  
  void startOfDay();
  void OnBar();
  void OnTick();
  
  //double rboPrice;
};

RboSetup::RboSetup(Enum_SIDE _side):SetupBase(Symbol(),_side) {
  strategyName = "RboSetup";
  side = _side;
  callOnTick = true;
  callOnBar = false;
  reset();
}


RboSetup::~RboSetup() {
}

void RboSetup::reset() {
  SetupBase::reset();
}

void RboSetup::startOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  reset();
}

void RboSetup::defaultParameters() {
}

void RboSetup::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  criteriaData();
  if(GoLong)
    triggered = longCriteria();
  else if(GoShort)
    triggered = shortCriteria();
}

void RboSetup::OnTick() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

bool RboSetup::longCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  return false;
}

bool RboSetup::shortCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  return false;
}

void RboSetup::criteriaData() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

