//+------------------------------------------------------------------+
//|                                                  BreakOutATS.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

extern string commentString_BO0 = ""; //---------------------------------------------
extern string commentString_BO1 = ""; //--------- BreakOut Trader ATS
extern string commentString_BO2 = ""; //---------------------------------------------
extern bool UseDefaultParameters = true; // Use pre-configured parameters for pattern
enum Enum_POI {POI_Close,POI_High,POI_Low,POI_Open,POI_Median,POI_Typical,POI_Weighted,
                 POI_MovAvg,POI_HHLL};
extern Enum_POI POI_Model = POI_Close;

enum Enum_DIST {DIST_Atr,DIST_Pips};
extern Enum_DIST Dist_Model = DIST_Atr;

extern string commentString_BO3 = ""; //---------------------------------------------
extern ENUM_APPLIED_PRICE POI_price = PRICE_CLOSE;
extern int                POI_bar_shift = 1;
extern ENUM_MA_METHOD     POI_ma_method = MODE_SMA;
extern int                POI_ma_period = 20;
extern ENUM_APPLIED_PRICE POI_ma_price = PRICE_CLOSE;
extern string commentString_BO5 = ""; //---------------------------------------------
extern ENUM_TIMEFRAMES    DIST_atr_timeframe = 0;
extern int                DIST_atr_period = 14;
extern double             DIST_atr_factor = 0.10;   // 1-15%

#include <dev\common.mqh>
#include <dev\candle_patterns.mqh>
#include <dev\ATS.mqh>
#include <dev\zts_lib.mqh>

class BreakOutATS : public ATS {

  void reset();
  void defaultParameters();
  void checkForNewEntry(double bid, double ask);
  //void checkForLongEntry();
  //void checkForShortEntry();

  double POI_Long,POI_Short,Distance;
  bool barPOI, tickPOI;
  bool barDist, tickDist;

  void setPOI();
  void setDistance();
  void updatePOI();
  void updateDistance();
  
public:
  BreakOutATS(Trader*);
  ~BreakOutATS();
  
  void OnInit();
  void startOfDay();
  void endOfDay();
  void OnBar();
  void OnTick();
};

BreakOutATS::BreakOutATS(Trader *t):ATS(t) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  strategyName = "BreakOutATS";
  callOnTick = true;
  callOnBar = false;
  reset();
}


BreakOutATS::~BreakOutATS() {
}

void BreakOutATS::OnInit() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  ATS::OnInit();
}

void BreakOutATS::reset() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  ATS::reset();
}

void BreakOutATS::defaultParameters() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

void BreakOutATS::OnTick() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(tickEntry && inTradeWindow())
    if(Testing)
      checkForNewEntry(Close[0],Close[0]+Spread*P2D);
    else
      checkForNewEntry(Bid,Ask);
  if(tickPOI)
    updatePOI();
  if(tickDist)
    updateDistance();

}

void BreakOutATS::OnBar() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(pendingOrders && iBarShift(NULL,0, submitTime) > MaxBarsPending) {
    Info("Max Pending Bars hit, pending orders canceled!!");
    pendingOrders = false;
    broker.deletePendingOrders(Symbol(),strategyName); 
  }
  if(inTradeWindow()) {
    if(barEntry)
      checkForNewEntry(Close[0],Close[0]);
    if(barPOI)
      updatePOI();
    if(barDist)
      updateDistance();
  }
}

void BreakOutATS::startOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  reset();
  setPOI();
  setDistance();
}

void BreakOutATS::endOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
    if(EX_Model == EX_EOD)
      broker.closeOpenTrades(Symbol(),strategyName);
    cleanUpEOD();
}

void BreakOutATS::checkForNewEntry(double b, double a) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  if(GoLong)
    Info("if("+NormalizeDouble(b,Digits)+" >= "+NormalizeDouble(POI_Long,Digits)+" + "+NormalizeDouble(Distance,Digits));
    if(b >= POI_Long+Distance)
      if(filtersPassed(Long))
        trader.stopEntryOrder(Long);
  if(GoShort)
    if(a <= POI_Short-Distance)
      if(filtersPassed(Short))
        trader.stopEntryOrder(Short);
}


void BreakOutATS::setPOI() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  barPOI = true;
  tickPOI = false;
  barDist = false;
  tickDist = false;
  switch (POI_Model) {
    case POI_Close:
      POI_Long = iClose(NULL,0,POI_bar_shift);
      POI_Short = POI_Long;
      break;
    case POI_High:
      POI_Long = iHigh(NULL,0,POI_bar_shift);
      POI_Short = POI_Long;
      break;
    case POI_Low:
      POI_Long = iLow(NULL,0,POI_bar_shift);
      POI_Short = POI_Long;
      break;
    case POI_Open:
      POI_Long = iOpen(NULL,0,POI_bar_shift);
      POI_Short = POI_Long;
      break;
    case POI_Median:
      POI_Long = (iHigh(NULL,0,POI_bar_shift)+iLow(NULL,0,POI_bar_shift)) / 2.0;
      POI_Short = POI_Long;
      break;
    case POI_Typical:
      POI_Long = (iHigh(NULL,0,POI_bar_shift)+iLow(NULL,0,POI_bar_shift) + iClose(NULL,0,POI_bar_shift)) / 3.0;
      POI_Short = POI_Long;
      break;
    case POI_Weighted:
      POI_Long = (iHigh(NULL,0,POI_bar_shift)+iLow(NULL,0,POI_bar_shift) + iClose(NULL,0,POI_bar_shift) + iClose(NULL,0,POI_bar_shift)) / 4.0;;
      POI_Short = POI_Long;
      break;
    case POI_MovAvg:
      POI_Long = iMA(NULL,0,POI_ma_period,0,POI_ma_method,POI_ma_price,0);
      POI_Short = POI_Long;
      break;
  }
}

void BreakOutATS::updatePOI() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  switch (POI_Model) {
    case POI_Close:
      POI_Long = iClose(NULL,0,POI_bar_shift);
      POI_Short = POI_Long;
      break;
    case POI_High:
      POI_Long = iHigh(NULL,0,POI_bar_shift);
      POI_Short = POI_Long;
      break;
    case POI_Low:
      POI_Long = iLow(NULL,0,POI_bar_shift);
      POI_Short = POI_Long;
      break;
    case POI_Open:
      POI_Long = iOpen(NULL,0,POI_bar_shift);
      POI_Short = POI_Long;
      break;
    case POI_Median:
      POI_Long = (iHigh(NULL,0,POI_bar_shift)+iLow(NULL,0,POI_bar_shift)) / 2.0;
      POI_Short = POI_Long;
      break;
    case POI_Typical:
      POI_Long = (iHigh(NULL,0,POI_bar_shift)+iLow(NULL,0,POI_bar_shift) + iClose(NULL,0,POI_bar_shift)) / 3.0;
      POI_Short = POI_Long;
      break;
    case POI_Weighted:
      POI_Long = (iHigh(NULL,0,POI_bar_shift)+iLow(NULL,0,POI_bar_shift) + iClose(NULL,0,POI_bar_shift) + iClose(NULL,0,POI_bar_shift)) / 4.0;;
      POI_Short = POI_Long;
      break;
    case POI_MovAvg:
      POI_Long = iMA(NULL,0,POI_ma_period,0,POI_ma_method,POI_ma_price,0);
      POI_Short = POI_Long;
      break;
  }
}


void BreakOutATS::setDistance() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  switch(Dist_Model) {
    case DIST_Atr:
      Distance = iATR(NULL,DIST_atr_timeframe,DIST_atr_period,0);
      Distance *= DIST_atr_factor * P2D;
      break;
    case DIST_Pips:
      break;
  }
}

void BreakOutATS::updateDistance() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}
