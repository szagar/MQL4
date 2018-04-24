//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

enum Enum_DIST {DIST_DayAtr,DIST_Atr,DIST_Pips};

extern string commentString_DISTO0 = ""; //---------------------------------------------
extern string commentString_DISTO1 = ""; //--------- BreakOut Distance
extern string commentString_DISTO2 = ""; //---------------------------------------------
extern Enum_DIST Dist_Model   = DIST_DayAtr;
extern ENUM_TIMEFRAMES    DIST_atr_timeframe = 0; //>> ATR timeframe
extern int                DIST_atr_period = 14;   //>> ATR period
extern double             DIST_atr_factor = 0.10; //>> ATR factor 1-15%
extern string commentString_DIST02 = ""; //---------------------------------------------

#include <dev\commonConstants.mqh>
//#include <dev\zts_lib.mqh>

class Distance {
public:
  Distance();
  ~Distance();
  
  double distance;

  double getDistance(int barShift);
};

Distance::Distance() {
}

Distance::~Distance() {
}

double Distance::getDistance(int barShift=1) {
  Info2(__FUNCTION__,__LINE__,"Entered");
  switch(Dist_Model) {
    case DIST_DayAtr:
      distance = iATR(NULL,PERIOD_D1,DIST_atr_period,0);
      distance *= DIST_atr_factor;  // * P2D;
      break;
    case DIST_Atr:
      distance = iATR(NULL,DIST_atr_timeframe,DIST_atr_period,0);
      distance *= DIST_atr_factor;  // * P2D;
      break;
    case DIST_Pips:
      distance = 10 * P2D;
      break;
  }
  Info2(__FUNCTION__,__LINE__,"Model: "+EnumToString(Dist_Model)+"  distance="+DoubleToStr(distance,Digits));
  return distance;
}

