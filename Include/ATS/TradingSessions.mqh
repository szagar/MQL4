//+------------------------------------------------------------------+
//|                                              TradingSessions.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//|  notes:
//|     - https://market24hclock.com
//|     - Stratgic Points:
//|           LSE  8:00am - 4:35pm
//|           NYSE 2:30pm - 9:00pm
//|           
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS\logger.mqh>

//#include <ATS/logger.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <ATS\tradingSessions_externs.mqh>

#ifndef TRADINGSESSIONS
#define TRADINGSESSIONS
#define NumSessions 9
#define NumSeasons 2
#endif

#define Start 0
#define End 1

class TradingSessions {
private:
  int gmt2serverOffset;
  int gmt2serverOffsetHrs;
  int local2gmtOffset;
  int local2gmtOffsetHrs;
  int local2serverOffset;
  int local2serverOffsetHrs;
  
  bool inSession;
  bool newDay;

  double LocalTime[NumSeasons][NumSessions][2];
  int getTZadj(string tz);

  Enum_Seasons season;
  
  datetime SessionTimes_Start[NumSessions];
  datetime SessionTimes_End[NumSessions];

  void initOffsets();
  void setTZoffsets();
  datetime today0time();
  //void initSessionTimes();
public:
  TradingSessions(Enum_Sessions _tradingSession=NewYork, Enum_Seasons _season=Winter);
  ~TradingSessions();

  
  datetime addDay(datetime);
  void setSession(Enum_Sessions);
  void setSessionMinMax();
  datetime previousSessionStart(datetime t=0);

  void setTradeWindow(Enum_Sessions,Enum_SessionSegments);
  bool tradeWindow(Enum_Sessions,Enum_SessionSegments);
  bool tradeWindow(datetime,Enum_Sessions);
  bool tradeWindowHr(Enum_Sessions,Enum_SessionSegments);
  
  void onNewBar(datetime barStart);
  void closeOfBar();
  
  string showSession(bool,string);
  void showAllSessions(string);

  bool isSOD(datetime);
  bool isSOS(datetime);
  
  datetime startTimeForSession(Enum_Sessions,string);
  datetime endTimeForSession(Enum_Sessions,string);
  
  Enum_Sessions tradingSession;
  double hiPrice, loPrice;
  datetime hiPriceDT,loPriceDT;

  int sessionBarNumber;
  
  datetime startOfDay;
  datetime endOfDay;
  
  datetime startTradingSession_Server;
  datetime endTradingSession_Server;
  
  datetime nextStartTradeWindow;
  datetime nextEndTradeWindow;

  datetime getStartTime(Enum_Sessions);    // local time
  datetime getEndTime(Enum_Sessions);      // local time


};

TradingSessions::TradingSessions(Enum_Sessions _tradingSession=NewYork, Enum_Seasons _season=Winter) {
  Print("TimeCurrent() = "+string(TimeCurrent()));
  Print("TimeLocal() = "+string(TimeLocal()));
  tradingSession = _tradingSession;
  season = _season;

  datetime today0 = today0time(); 

  startOfDay = today0 + 1*60*60;;
    endOfDay = today0 + 17*60*60;

  setTZoffsets();
  initOffsets();
  
  setSession(tradingSession);
  Print("TradingSessions::  nextStartTradeWindow="+(string)nextStartTradeWindow);
  Print("TradingSessions::  nextEndTradeWindow="+(string)nextEndTradeWindow);
}

void TradingSessions::setTZoffsets() {
  Print("setTZoffsets() Entered");
  datetime local,current,gmt;
  if(Testing) {
    datetime today0 = today0time(); 
    gmt = today0;   //StructToTime(dtStruct);
    local = gmt - 5*60*60;
    current = gmt + 2*60*60;
  } else {
    local = TimeLocal();
    current = TimeCurrent();
    gmt = TimeGMT();
  }
  gmt2serverOffset = int((current-gmt)/60)*60;  //    server = GMT + 2
  local2gmtOffset = int((gmt - local)/60)*60;  //TimeGMTOffset();   local = GMT - 5
  local2serverOffset = int((current - local)/60)*60;

  gmt2serverOffsetHrs = int(gmt2serverOffset / (60*60));
  local2gmtOffsetHrs = int(local2gmtOffset / (60*60));
  local2serverOffsetHrs = int(local2serverOffset / (60*60));

  Print("SanityCheck:  gmt2serverOffset  ="+string(gmt2serverOffset));
  Print("SanityCheck:  local2gmtOffset   ="+string(local2gmtOffset));
  Print("SanityCheck:  local2serverOffset="+string(local2serverOffset));
  Print("SanityCheck:  "+string(local2gmtOffset)+" + "+string(gmt2serverOffset)+" = "+string(local2serverOffset));
  
  Print("SanityCheck:  gmt2serverOffsetHrs  ="+string(gmt2serverOffsetHrs));
  Print("SanityCheck:  local2gmtOffsetHrs      ="+string(local2gmtOffsetHrs));
  Print("SanityCheck:  local2serverOffsetHrs="+string(local2serverOffsetHrs));
  Print("SanityCheck:  "+string(local2gmtOffsetHrs)+" + "+string(gmt2serverOffsetHrs)+" = "+string(local2serverOffsetHrs));
}  

void TradingSessions::setSession(Enum_Sessions ts) {
  //Print("setSession() Entered");
  tradingSession = ts;
  setTradeWindow(tradingSession);
}

void TradingSessions::setTradeWindow(Enum_Sessions ts = tbd, Enum_SessionSegments seg=all) {
  //Print("setTradeWindow() Entered");
  nextStartTradeWindow = getStartTime(ts);   //  local time 
  nextEndTradeWindow   = getEndTime(ts);     //  local time
  //Print(__FUNCTION__,__LINE__,"session("+EnumToString(ts)+")  time: "
  //      +(string)nextStartTradeWindow+" :: "
  //      +(string)nextEndTradeWindow);
  if(seg>all) {
    int segDuration = (int)(nextEndTradeWindow - nextStartTradeWindow)/3;
    segDuration = int(segDuration/60 - MathMod(segDuration/60,Period()))*60;
    if(seg>first) {
      nextStartTradeWindow += segDuration*(seg-1);
    }
    if(seg<third) {
      nextEndTradeWindow -= segDuration*(3-seg);
    }
  }
}





datetime TradingSessions::today0time() {
  //Print("today0time() Entered");
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;
  return StructToTime(dtStruct);
}

// local time of next session start
datetime TradingSessions::getStartTime(Enum_Sessions ts) {
  //Print("getStartTime() Entered");
  return(datetime((int)today0time() + int(LocalTime[season][ts][Start]*60*60)));
}

// local time of next session end
datetime TradingSessions::getEndTime(Enum_Sessions ts) {
  //Print("getEndTime() Entered");
  return(datetime((int)today0time() + int(LocalTime[season][ts][End]*60*60)));
}

TradingSessions::~TradingSessions() {
  Print("~TradingSessions() Entered");
}
  
void TradingSessions::initOffsets() {
  //Print("initOffsets() Entered");
  season = Winter;
  LocalTime[season][Asia][Start]      = 19;
  LocalTime[season][Asia][End]        =  4;
  LocalTime[season][AsiaLast1][Start] =  3;
  LocalTime[season][AsiaLast1][End]   =  4;
  LocalTime[season][London][Start]    =  3;
  LocalTime[season][London][End]      = 12;
  LocalTime[season][NewYork][Start]   =  8;
  LocalTime[season][NewYork][End]     = 16;
  LocalTime[season][NYSE][Start]      =  9.5;
  LocalTime[season][NYSE][End]        = 16;
  LocalTime[season][NYlast1][Start]   = 15;
  LocalTime[season][NYlast1][End]     = 16;
  LocalTime[season][LondonClose][Start] = 11;
  LocalTime[season][LondonClose][End]   = 12;
}

int TradingSessions::getTZadj(string tz) {
  //Print("getTZadj() Entered");
  if(StringCompare(tz,"server",false)==0)
    return(local2serverOffset);
  if(StringCompare(tz,"local",false)==0)
    return(0);
  if(StringCompare(tz,"gmt",false)==0)
    return(-local2gmtOffset);
  return(0);
}

string TradingSessions::showSession(bool detail=false,string tz="Server") {
  //Print("showSession() Entered");
  string rtn = EnumToString(tradingSession);
  int adj = getTZadj(tz);
  Print("adj="+string(adj));
  if(detail)
    rtn += ":  "+string(getStartTime(tradingSession)+adj)+" - "+string(getEndTime(tradingSession)+adj);
    
  return rtn;
}

void TradingSessions::showAllSessions(string tz = "server") {
  //Print("showAllSessions() Entered");
  int adj = getTZadj(tz);
  string str;
  Enum_Sessions save = tradingSession;
  for(Enum_Sessions i=0; i<EnumLast; i++ ) {
    //setSession(i);
    str = StringFormat("Session: %-10s: %s - %s",EnumToString(i),TimeToStr(getStartTime(i)+adj),TimeToString(getEndTime(i)+adj));
    Print(str);
  }
  setSession(save);
}

datetime TradingSessions::previousSessionStart(datetime t=0) {
  Print("previousSessionStart() Entered");
  if(t==0) t = TimeCurrent();
  MqlDateTime dtStruct;
  TimeToStruct(t, dtStruct);
  dtStruct.hour = TimeHour(SessionTimes_Start[NYSE] + gmt2serverOffsetHrs);
  dtStruct.min = TimeMinute(SessionTimes_Start[NYSE]);
  dtStruct.sec = 0;
  return(StructToTime(dtStruct));
}

bool TradingSessions::tradeWindowHr(Enum_Sessions ts = tbd, Enum_SessionSegments seg=all) {
  Print("tradeWindowHr() Entered");
  int startTime,stopTime;
  if(ts == All) return true;
  if(ts == tbd) ts = tradingSession;
  
  startTime = int(SessionTimes_Start[ts] + gmt2serverOffsetHrs);
  stopTime = int(SessionTimes_End[ts] + gmt2serverOffsetHrs);
  if(seg>all) {
    int segDuration = (stopTime - startTime)/3;
    if(seg>first) {
      startTime += segDuration*(seg-1);
    }
    if(seg<third) {
      stopTime -= segDuration*(3-seg);
    }
  }
  startTime = TimeHour(startTime);
  stopTime = TimeHour(stopTime);
  
  //startTime = TimeHour(SessionTimes_Start[ts] + gmt2serverOffsetHrs);
  //stopTime = TimeHour(SessionTimes_End[ts] + gmt2serverOffsetHrs);
  int currentHour = TimeHour(TimeCurrent());
  if ( (startTime < stopTime)  && (currentHour < startTime  || currentHour >= stopTime) ) return (FALSE);
  if ( (startTime > stopTime)  && (currentHour < startTime)  && (currentHour >= stopTime) ) return (FALSE);
  if (stopTime  == 0.0) stopTime  = 24;
  if (Hour() == stopTime  - 1.0 && Minute() >= 59) return (FALSE);
  return (TRUE);
}

bool TradingSessions::tradeWindow(Enum_Sessions ts = tbd, Enum_SessionSegments seg=all) {
  Print("tradeWindow() Entered");
  int startTime,startMinute,stopTime;
  if(ts == All) return true;
  if(ts == tbd) ts = tradingSession;
  
  startTime = (int)nextStartTradeWindow;
  stopTime  = (int)nextEndTradeWindow;
  
  //Info2(__FUNCTION__,__LINE__,"segment("+EnumToString(seg)+") time: "+(string)(datetime)startTime+" :: "+(string)(datetime)stopTime);
  int startHour = TimeHour(startTime);
  startMinute = TimeMinute(startTime);
  stopTime = TimeHour(stopTime);

  int currentHour = TimeHour(TimeCurrent());
  int currentMinute = TimeMinute(TimeCurrent());
  //Info2(__FUNCTION__,__LINE__,"Check: "+(string)currentHour+":"+(string)currentMinute);
  if ( (startHour < stopTime)  && (currentHour < startHour  || currentHour >= stopTime) ) return (FALSE);
  if ( (startHour < stopTime)  && (currentHour < startHour  ||
                                   (currentHour == startHour && currentMinute < startMinute) || 
                                   currentHour >= stopTime) ) return (FALSE);
  if ( (startHour > stopTime)  && (currentHour < startHour)  && (currentHour >= stopTime) ) return (FALSE);
  if (stopTime  == 0.0) stopTime  = 24;
  if (Hour() == stopTime  - 1.0 && Minute() >= 59) return (FALSE);
  return (TRUE);
}

datetime TradingSessions::addDay(datetime to) {
  Print("addDay() Entered");
  //Debug(__FUNCTION__,__LINE__,string(to)+" -> "+string(to + 24*60*60));
  return(to + 24*60*60);
}

void TradingSessions::setSessionMinMax() {
  Print("setSessionMinMax() Entered");
  //Debug(__FUNCTION__,__LINE__,"Entered");

  datetime start = startTradingSession_Server;
  datetime end = endTradingSession_Server;
  
  datetime TimeCopy[];
  double HighPrices[];
  double LowPrices[];

  ArrayCopy(TimeCopy, Time, 0, 0, WHOLE_ARRAY);
  ArrayCopy(HighPrices, High, 0, 0, WHOLE_ARRAY);
  ArrayCopy(LowPrices, Low, 0, 0, WHOLE_ARRAY);

  hiPrice = 0.0;
  loPrice = 9999.99;
  datetime nowDt = TimeCopy[0];
  if (nowDt < end) end = nowDt;
  int candlePeriod = int(TimeCopy[0] - TimeCopy[1]);
  int interval = int((nowDt - start)/ candlePeriod);
  while(TimeCopy[interval] <= end && interval > 0) {
    if (HighPrices[interval] > hiPrice) {
      hiPrice = HighPrices[interval];
      hiPriceDT = TimeCopy[interval];
    }
    if (LowPrices[interval] < loPrice) {
      loPrice = LowPrices[interval];
      loPriceDT = TimeCopy[interval];
    }
    interval--;
  }
}

datetime TradingSessions::startTimeForSession(Enum_Sessions thisSession,string tz="Server") {
  Print("startTimeForSession() Entered");
  if(StringCompare(tz,"Server")==0)
    return SessionTimes_Start[thisSession] + gmt2serverOffset;
  return NULL;
}

datetime TradingSessions::endTimeForSession(Enum_Sessions thisSession,string tz="Server") {
  Print("endTimeForSession() Entered");
  if(StringCompare(tz,"Server")==0)
    return SessionTimes_End[thisSession] + gmt2serverOffset;
  return NULL;
}

bool TradingSessions::isSOD(datetime t=0) {
  Print("isSOD() Entered");
  if(t==0) t = TimeCurrent();
  //Info2(__FUNCTION__,__LINE__,"t="+(string)t+"   startOfDay="+(string)startOfDay);
  if(t >= startOfDay) {
    newDay = true;
    return true;
  }
  return(false);
}

bool TradingSessions::isSOS(datetime t=0) {
  Print("isSOS() Entered");
  //Info2(__FUNCTION__,__LINE__,"Entered");
  if(t==0) t = TimeCurrent();
  //Info2(__FUNCTION__,__LINE__,(string)t+" == "+(string)(datetime)nextStartTradeWindow);
  if(t == nextStartTradeWindow) {
    inSession = true;
    setTradeWindow();
    return true;
  }
  return(false);
}

void TradingSessions::onNewBar(datetime barStart) {
  Print("onNewBar() Entered");
  if(barStart>nextEndTradeWindow)
    inSession = false;
  if(inSession)
    sessionBarNumber++;
  else
    sessionBarNumber = 0;
}

void TradingSessions::closeOfBar() {
  Print("closeOfBar() Entered");
  if(newDay) {
    newDay = false;
    startOfDay = addDay(startOfDay);
  }
}
