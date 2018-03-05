//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS\distance_externs.mqh>

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

