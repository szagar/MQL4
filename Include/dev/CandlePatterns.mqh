//+------------------------------------------------------------------+
//|                                               CandlePatterns.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_CP0 = ""; //---------------------------------------------
extern string commentString_CP1 = ""; //--------- Candle Patterns setups
extern string commentString_CP2 = ""; //---------------------------------------------
extern int    CP_ConfirmBarsBack = 6; //<< number of candles back to confirm
extern ENUM_TIMEFRAMES CP_AtrPeriod = PERIOD_D1; //-   ATR timeframe
extern int CP_AtrBars = 10;                      //-   ATR period
extern double CP_AtrMaxFactor = 3.0;             //-   ATR factor for max range
extern double CP_AtrMinFactor = 1.2;             //-   ATR factor for min range


#include <dev\common.mqh>
#include <dev\candle_patterns.mqh>
#include <dev\SetupBase.mqh>
#include <dev\zts_lib.mqh>

class CandlePatterns : public SetupBase {

  int crossFastUp;
  int crossFastDn;
  void reset();
  void defaultParameters();

  void criteriaData();
  bool longCriteria();
  bool shortCriteria();
  
  double ma_curr[8], ma_prev[8];
  double ma_v_px[8], ma_slope[8];
  double ma_curr_sod;
  double ma_prev_sod;
  double ma_slope_sod;
  
  double ma_01_curr, ma_02_curr;

public:
  CandlePatterns(Enum_SIDE);
  ~CandlePatterns();
  
  //bool triggered();
  void startOfDay();
  void OnBar();
  void OnTick();
};

CandlePatterns::CandlePatterns(Enum_SIDE _side):SetupBase(Symbol(),_side) {
  strategyName = "CandlePatterns";
  side = _side;
  callOnTick = false;
  callOnBar = true;
  reset();
}


CandlePatterns::~CandlePatterns() {
}

void CandlePatterns::reset() {
  SetupBase::reset();
}

void CandlePatterns::startOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  reset();
  switch (CP_Model) {
    case CP_BIG_SHADOW:
      break;
  }
}

void CandlePatterns::defaultParameters() {
  switch (CP_Model) {
    case CP_BIG_SHADOW:
      CP_AtrPeriod = PERIOD_D1;
      CP_AtrMaxFactor = 3.0;
      CP_AtrMinFactor = 1.2;
      break;
  }
}

void CandlePatterns::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  criteriaData();
  if(GoLong)
    triggered = longCriteria();
  else if(GoShort)
    triggered = shortCriteria();
  
}

void CandlePatterns::OnTick() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

bool CandlePatterns::longCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double atr, maxSize, minSize, range;
  if(Volume[0]>1) return false;

  switch (CP_Model) {
    case CP_BIG_SHADOW:
      if(!candlePattern_BigShadow())
        return false;
      Comment("Big Shadow");
      markOnChart(Time[1],iHigh(NULL,0,1)+50*PipSize);
      if(!candlePattern_BiggestRange(CP_ConfirmBarsBack))
        return false;
      Comment("Biggest Range");
      
      range = iHigh(NULL,0,1) - iLow(NULL,0,1);
      atr = calc_ATR(Symbol(),CP_AtrPeriod,CP_AtrBars);
      maxSize = atr*CP_AtrMaxFactor;
      minSize = atr*CP_AtrMinFactor;
      Comment("Size: "+minSize+" < "+range+" < "+maxSize);
      if(atr>maxSize)
        return false;
      if(atr<minSize)
        return false;
      Comment("Good Size");
      if(CP_Optimize) {
        
      }
      return true;
      break;
  }
  return false;
}

bool CandlePatterns::shortCriteria() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(Volume[0]>1) return false;
  return false;
}

void CandlePatterns::criteriaData() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

