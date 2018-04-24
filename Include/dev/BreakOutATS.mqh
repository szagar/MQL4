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
//enum Enum_POI {POI_Close,POI_High,POI_Low,POI_Open,POI_Median,POI_Typical,POI_Weighted,
//                 POI_MovAvg,POI_HHLL};
//enum Enum_DIST {DIST_DayAtr,DIST_Atr,DIST_Pips};

//extern Enum_POI POI_Model   = POI_Close;
//extern Enum_DIST Dist_Model = DIST_DayAtr;
extern int MaxTradesPerDay  = 1;
extern bool UseStopLoss    = true;
extern bool UseTrailingStop = false;
extern bool UseTakeProfit   = true;
extern bool UseEODexit      = true;
extern bool UseTimeInExit   = false;
extern bool UseBarsInExit   = false;
extern bool UseTODexit      = false;

#include <dev\Poi.mqh>
#include <dev\Distance.mqh>
/**
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
**/

#include <dev\common.mqh>
#include <dev\candle_patterns.mqh>
#include <dev\ATS.mqh>
#include <dev\zts_lib.mqh>
//#include <dev\TradingSessions.mqh>

class BreakOutATS : public ATS {

  void reset();
  void defaultParameters();
  void checkForNewEntry(double bid, double ask);

  //double distance;
  bool barPOI, tickPOI;
  bool barDist, tickDist;
  int tradeCnt;
  Distance *dist;
  Poi *poi;
  
  //void setPOI();
  //void setDistance();
  //void updatePOI();
  //void updateDistance();
  
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
  barPOI = true;
  dist = new Distance();
  poi = new Poi();
  reset();
}


BreakOutATS::~BreakOutATS() {
  if (CheckPointer(poi) == POINTER_DYNAMIC) delete poi;
  if (CheckPointer(dist) == POINTER_DYNAMIC) delete dist;
}

void BreakOutATS::reset() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  ATS::reset();
  tradeCnt = 0;
}


void BreakOutATS::OnInit() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  ATS::OnInit();  
}

void BreakOutATS::defaultParameters() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

void BreakOutATS::OnTick() {
  //Debug(__FUNCTION__,__LINE__,"Entered");
  if(UseTODexit && TimeCurrent() > Time2CloseTrades) {
    broker.closeOpenTrades(Symbol(),strategyName);
    broker.deletePendingOrders(Symbol(),strategyName);
  }
  if(tickEntry && tradeCnt<=MaxTradesPerDay && inTradeWindow())
    if(Testing)
      checkForNewEntry(Close[0],Close[0]+Spread*P2D);
    else
      checkForNewEntry(Bid,Ask);
  if(tickPOI)
    poi.setPOI(0);
    //updatePOI();
  if(tickDist)
    dist.getDistance();
    //distance = dist.distance;

}

void BreakOutATS::OnBar() {
  //Debug(__FUNCTION__,__LINE__,"Entered");
  ATS::OnBar();

//extern bool UseTimeInExit   = false;
  if(UseBarsInExit && (barNumber-entryBar)>BarsInTrade) {
    broker.closeOpenTrades(Symbol(),strategyName);
    broker.deletePendingOrders(Symbol(),strategyName);
  }
  if(pendingOrders && iBarShift(NULL,0, submitTime) > MaxBarsPending) {
    Info("Max Pending Bars hit, pending orders canceled!!");
    pendingOrders = false;
    broker.deletePendingOrders(Symbol(),strategyName); 
  }
  if(inTradeWindow()) {
    Info2(__FUNCTION__,__LINE__,"inTradeWindow()");
    if(barPOI) {
      Info2(__FUNCTION__,__LINE__,"barPOI");
      if(sessionTool.isSOS(Time[0])) {
        Info2(__FUNCTION__,__LINE__,"isSOS("+(string)Time[0]+")");
        poi.setPOI(1);
      }
      //updatePOI();
    }
    if(barEntry && poi.poiIsSet && tradeCnt<MaxTradesPerDay) {
      Info2(__FUNCTION__,__LINE__,"barEntry && tradeCnt<MaxTradesPerDay");
      checkForNewEntry(Close[0],Close[0]);
    }
    if(barDist) {
      Info2(__FUNCTION__,__LINE__,"barDist");
      dist.getDistance();
      //distance = dist.distance;
    }
  }
}

void BreakOutATS::startOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  reset();
  sessionTool.setTradeWindow(Session,SessionSegment);
  //poi.reset();
  dist.getDistance();
  filters.setDaily();
}

void BreakOutATS::endOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  Debug(__FUNCTION__,__LINE__,"EX_Model="+EnumToString(EX_Model));
  broker.PrintOpenTrades();
  broker.PrintPendingOrders();
  if(UseEODexit) { 
    broker.closeOpenTrades(Symbol(),strategyName);
    broker.deletePendingOrders(Symbol(),strategyName);
  }
  cleanUpEOD();
}

void BreakOutATS::checkForNewEntry(double b, double a) {
  Info2(__FUNCTION__,__LINE__,"Entered");
  //double boLong, boShort;
  SetupStruct *setup;
  if(GoLong) {
    Info2(__FUNCTION__,__LINE__,"if("+string(NormalizeDouble(b,Digits))+" >= "+
               string(NormalizeDouble(poi.POI_Long,Digits))+" + "+
               string(NormalizeDouble(dist.distance,Digits)));
    if(filtersPassed(Long)) {
      Info2(__FUNCTION__,__LINE__,"Long filter passed");
      if(b >= poi.POI_Long+dist.distance) {
        setup = new SetupStruct();
        setup.strategyName = strategyName;
        setup.side         = Long;
        setup.symbol       = Symbol();
        setup.stopPrice    = a+5*P2D;
        trader.stopEntryOrder(setup);
        tradeCnt++;
      }
    }
  }
  if(GoShort) {
    Info("if("+string(NormalizeDouble(a,Digits))+" >= "+
               string(NormalizeDouble(poi.POI_Short,Digits))+" + "+
               string(NormalizeDouble(dist.distance,Digits)));
    if(filtersPassed(Short)) {
      Info2(__FUNCTION__,__LINE__,"Short filter passed");
      if(a <= poi.POI_Short-dist.distance) {
        setup = new SetupStruct();
        setup.strategyName = strategyName;
        setup.side         = Short;
        setup.symbol       = Symbol();
        setup.stopPrice    = b;
        Info2(__FUNCTION__,__LINE__,"call stopEntryOrder for SHort");
        trader.stopEntryOrder(setup);
        tradeCnt++;
      }
    }
  }
}

/**
void BreakOutATS::setPOI() {
  Info2(__FUNCTION__,__LINE__,"Entered");
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
  Info2(__FUNCTION__,__LINE__,"POI_Long="+DoubleToStr(POI_Long,Digits)+"  POI_Short="+DoubleToStr(POI_Short,Digits));
}

void BreakOutATS::updatePOI() {
  Info2(__FUNCTION__,__LINE__,"Entered");
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
  Info2(__FUNCTION__,__LINE__,"POI_Long="+DoubleToStr(POI_Long,Digits)+"  POI_Short="+DoubleToStr(POI_Short,Digits));
}
**/

/**
void BreakOutATS::setDistance() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  switch(Dist_Model) {
    case DIST_DayAtr:
      Distance = iATR(NULL,PERIOD_D1,DIST_atr_period,0);
      Distance *= DIST_atr_factor;  // * P2D;
      break;
    case DIST_Atr:
      Distance = iATR(NULL,DIST_atr_timeframe,DIST_atr_period,0);
      Distance *= DIST_atr_factor;  // * P2D;
      break;
    case DIST_Pips:
      break;
  }
}

void BreakOutATS::updateDistance() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}
**/
