//+------------------------------------------------------------------+
//|                                               ChartTools.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev\TradingSessions.mqh>
#include <dev\logger.mqh>

class ChartTools {
private:
  string Prefix;
  color RangeLinesColor;
  TradingSessions *session;
  
  //void findPeriodMinMax(datetime, datetime);
  void plotRangeLines(string prefix, datetime hiStart, datetime hiEnd,
                                               datetime loStart, datetime loEnd,
                                               double hiPrice, double loPrice, bool,bool);

public:
  ChartTools();
  ~ChartTools();
  
  void drawRange_session(Enum_Sessions,bool);
  void drawRange_day();
  
  double getSessionHigh(string);
  double getSessionLow(string);

  void cleanUp();
};

ChartTools::ChartTools() {
  Debug(__FUNCTION__,__LINE__,"Entered");
  Prefix = "CT_";
  RangeLinesColor = Yellow;
}

ChartTools::~ChartTools() {
  Debug(__FUNCTION__,__LINE__,"Entered");
}

void ChartTools::drawRange_session(Enum_Sessions sessionName, bool showLabel=true) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  session = new TradingSessions(sessionName);
  session.setSessionMinMax();
  Prefix = "ChT_"+EnumToString(session.tradingSession);
  Debug(__FUNCTION__,__LINE__,"Prefix="+Prefix);
  datetime start = session.startTradingSession_Server;
  datetime end = session.endTradingSession_Server;
  Debug(__FUNCTION__,__LINE__,"start="+TimeToStr(start)+"->"+TimeToStr(end));

  datetime endDt = session.endTradingSession_Server;
  datetime startDt = session.startTradingSession_Server;
  //plotRangeLines(prefix,session.hiPriceDT,endDt,session.loPriceDT,endDt,session.hiPrice,session.loPrice,true);
  plotRangeLines(Prefix,startDt,endDt,startDt,endDt,session.hiPrice,session.loPrice,true,showLabel);
  if (CheckPointer(session) == POINTER_DYNAMIC) delete session;
}

double ChartTools::getSessionHigh(string _session) {
  string name = "ChT_"+_session+"_DayHighArrow";
  if (ObjectFind(0, name) == 0) 
    return(ObjectGetDouble(0,name,OBJPROP_PRICE1));
  Debug(__FUNCTION__,__LINE__,name+" not found");
  return NULL;
}

double ChartTools::getSessionLow(string _session) {
  string name = "ChT_"+_session+"_DayLowArrow";
  if (ObjectFind(0, name) == 0) 
    return(ObjectGetDouble(0,name,OBJPROP_PRICE1));
  Debug(__FUNCTION__,__LINE__,name+" not found");
  return NULL;
}

void ChartTools::plotRangeLines(string prefix, datetime hiStart, datetime hiEnd,
                                               datetime loStart, datetime loEnd,
                                               double hiPrice, double loPrice,
                                               bool leftArrow=false, bool showLabel=true) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  
  datetime arrowDt;
  int arrowType = OBJ_ARROW_RIGHT_PRICE;
  if(leftArrow) arrowType = OBJ_ARROW_LEFT_PRICE;
  
  if(hiEnd==0) hiEnd = hiStart + 19*60*60;
  if(loEnd==0) loEnd = loStart + 19*60*60;

  Debug(__FUNCTION__,__LINE__,"Draw: "+Prefix+" ...");
  if (ObjectFind(0, Prefix + "_DayRangeHigh") == 0)
    ObjectDelete(0, Prefix + "_DayRangeHigh");
  if (ObjectFind(0, Prefix + "_DayRangeLow") == 0)
    ObjectDelete(0, Prefix + "_DayRangeLow");
  if (ObjectFind(0, Prefix + "_DayHighArrow") == 0)
    ObjectDelete(0, Prefix + "_DayHighArrow");
  if (ObjectFind(0, Prefix + "_DayLowArrow") == 0)
    ObjectDelete(0, Prefix + "_DayLowArrow");

  Debug(__FUNCTION__,__LINE__,"Draw: "+Prefix + "_DayRangeHigh: "+DoubleToStr(hiPrice,Digits));
  ObjectCreate(0, Prefix + "_DayRangeHigh", OBJ_TREND, 0, hiStart,
               hiPrice, hiEnd, hiPrice);
  ObjectSetInteger(0, Prefix + "_DayRangeHigh", OBJPROP_COLOR, RangeLinesColor);
  ObjectSet(Prefix + "_DayRangeHigh", OBJPROP_RAY, false);

  Debug(__FUNCTION__,__LINE__,"Draw: "+Prefix + "_DayHighArrow");
  arrowDt = hiEnd;
  if(leftArrow) arrowDt = hiStart;
  ObjectCreate(0, Prefix + "_DayHighArrow", arrowType, 0,
               arrowDt, hiPrice);
  ObjectSetInteger(0, Prefix + "_DayHighArrow", OBJPROP_COLOR, Blue);
  if(!showLabel)
    ObjectSet(Prefix + "_DayHighArrow",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);

  Debug(__FUNCTION__,__LINE__,"Draw: "+Prefix + "_DayRangeLow");
  ObjectCreate(0, Prefix + "_DayRangeLow", OBJ_TREND, 0, loStart, 
               loPrice, loEnd, loPrice);               
  ObjectSetInteger(0, Prefix + "_DayRangeLow", OBJPROP_COLOR, RangeLinesColor);
  ObjectSet(Prefix + "_DayRangeLow", OBJPROP_RAY, false);

  arrowDt = loEnd;
  if(leftArrow) arrowDt = loStart;
  ObjectCreate(0, Prefix + "_DayLowArrow", arrowType, 0,
               arrowDt, loPrice);
  ObjectSetInteger(0, Prefix + "_DayLowArrow", OBJPROP_COLOR, Blue);
  if(!showLabel)
    ObjectSet(Prefix + "_DayLowArrow",OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
}
