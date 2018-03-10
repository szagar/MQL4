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

  double LocalTime[NumSeasons][NumSessions][2];
  int getTZadj(Enum_TIME_ZONES tz);

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

  
  bool newDayBar, newSessionBar;

  datetime addDay(datetime,int);
  void setSession(Enum_Sessions);
  void setSessionMinMax(Enum_Sessions);
  datetime previousSessionStart(datetime t=0);

  void setTradeWindow(Enum_Sessions,Enum_SessionSegments);
  bool tradeWindow(Enum_Sessions,Enum_SessionSegments);
  bool tradeWindow2();
  bool tradeWindow(datetime,Enum_Sessions);
  bool tradeWindowHr(Enum_Sessions,Enum_SessionSegments);
  
  void onNewBar(datetime barStart);
  void closeOfBar();
  
  string showSession(bool,Enum_TIME_ZONES);
  void showAllSessions(Enum_TIME_ZONES);

  bool isSOD(datetime);
  bool isEOD(datetime);
  bool isSOS(datetime);
  bool isEOS(datetime);
  
//  datetime startTimeForSession(Enum_Sessions,string);
//  datetime endTimeForSession(Enum_Sessions,string);
  
  Enum_Sessions tradingSession;
  double hiPrice, loPrice;
  datetime hiPriceDT,loPriceDT;

  int dayBarNumber,sessionBarNumber;
  
  datetime startOfDay;
  datetime endOfDay;
  
  //datetime startTradingSession_Server;
  //datetime endTradingSession_Server;
  
  datetime nextStartTradeWindow;
  datetime nextEndTradeWindow;

  datetime getStartTime(Enum_Sessions);    // local time
  datetime getEndTime(Enum_Sessions);      // local time
  datetime getNextSessionStart(Enum_Sessions, datetime);
  datetime getNextSessionEnd(Enum_Sessions, datetime);

  datetime sessionStartTime(Enum_TIME_ZONES,int);
  datetime sessionEndTime(Enum_TIME_ZONES,int);

};

TradingSessions::TradingSessions(Enum_Sessions _tradingSession=NewYork, Enum_Seasons _season=Winter) {
  //Print("TimeCurrent() = "+string(TimeCurrent()));
  //Print("TimeLocal() = "+string(TimeLocal()));
  tradingSession = _tradingSession;
  season = _season;

  datetime today0 = today0time(); 

  startOfDay = today0 + 17*60*60;  // + 24*60*60;
    endOfDay = startOfDay;   // + 24*60*60;   //today0 + 24*60*60 + 17*60*60;
  //Print(__FUNCTION__,__LINE__,"startOfDay=",startOfDay);
  //Print(__FUNCTION__,__LINE__,"endOfDay=",endOfDay);

  setTZoffsets();
  initOffsets();
  
  setSession(tradingSession);
  //Print("TradingSessions::  nextStartTradeWindow="+(string)nextStartTradeWindow);
  //Print("TradingSessions::  nextEndTradeWindow="+(string)nextEndTradeWindow);
}

void TradingSessions::setTZoffsets() {
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
  tradingSession = ts;
  setTradeWindow(tradingSession);
}

void TradingSessions::setTradeWindow(Enum_Sessions ts = tbd, Enum_SessionSegments seg=all) {
  nextStartTradeWindow = getStartTime(ts);   //  local time 
  nextEndTradeWindow   = getEndTime(ts);     //  local time
  //nextStartTradeWindow = getNextSessionStart(ts);  //getStartTime(ts);   //  local time 
  //nextEndTradeWindow   = getNextSessionEnd(ts);    //getEndTime(ts);     //  local time
  //Print("setTradeWindow: nextStartTradeWindow=",nextStartTradeWindow,"   nextEndTradeWindow=",nextEndTradeWindow);
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
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;
  return StructToTime(dtStruct);
}


TradingSessions::~TradingSessions() {
}
  
void TradingSessions::initOffsets() {
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

int TradingSessions::getTZadj(Enum_TIME_ZONES tz) {
  if(tz==server) return(local2serverOffset);
  if(tz==local) return(0);
  if(tz==gmt) return(-local2gmtOffset);
  return(0);
}

string TradingSessions::showSession(bool detail=false,Enum_TIME_ZONES tz=server) {
  string rtn = EnumToString(tradingSession);
  int adj = getTZadj(tz);
  //Print("adj="+string(adj));
  if(detail)
    rtn += ":  "+string(getNextSessionStart(tradingSession)+adj)+" - "+string(getNextSessionEnd(tradingSession)+adj);
    //rtn += ":  "+string(getStartTime(tradingSession)+adj)+" - "+string(getEndTime(tradingSession)+adj);
    
  return rtn;
}

void TradingSessions::showAllSessions(Enum_TIME_ZONES tz=server) {
  int adj = getTZadj(tz);
  string str;
  Enum_Sessions save = tradingSession;
  for(Enum_Sessions i=0; i<EnumLast; i++ ) {
    str = StringFormat("Session: %-10s: %s - %s",EnumToString(i),TimeToStr(getNextSessionStart(i)+adj),TimeToString(getNextSessionEnd(i)+adj));
    //str = StringFormat("Session: %-10s: %s - %s",EnumToString(i),TimeToStr(getStartTime(i)+adj),TimeToString(getEndTime(i)+adj));
    Print(str);
  }
}

//datetime TradingSessions::previousSessionStart(datetime t=0) {
//  Print("previousSessionStart() Entered");
//  if(t==0) t = TimeCurrent();
//  MqlDateTime dtStruct;
//  TimeToStruct(t, dtStruct);
//  dtStruct.hour = TimeHour(SessionTimes_Start[NYSE] + gmt2serverOffsetHrs);
//  dtStruct.min = TimeMinute(SessionTimes_Start[NYSE]);
//  dtStruct.sec = 0;
//  return(StructToTime(dtStruct));
//}

bool TradingSessions::tradeWindowHr(Enum_Sessions ts = tbd, Enum_SessionSegments seg=all) {
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
  
  int currentHour = TimeHour(TimeCurrent());
  if ( (startTime < stopTime)  && (currentHour < startTime  || currentHour >= stopTime) ) return (FALSE);
  if ( (startTime > stopTime)  && (currentHour < startTime)  && (currentHour >= stopTime) ) return (FALSE);
  if (stopTime  == 0.0) stopTime  = 24;
  if (Hour() == stopTime  - 1.0 && Minute() >= 59) return (FALSE);
  return (TRUE);
}

bool TradingSessions::tradeWindow2() {
  return inSession;
}

bool TradingSessions::tradeWindow(Enum_Sessions ts = tbd, Enum_SessionSegments seg=all) {
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

datetime TradingSessions::addDay(datetime to,int ndays=1) {
  int sign = 1;
  if(ndays<0) sign=-1;
  datetime dt = to + ndays*24*60*60;
  if(TimeDayOfWeek(dt)==0 && sign==1) dt += sign*24*60*60;
  if(TimeDayOfWeek(dt)==6 && sign==1) dt += sign*2*24*60*60;
  if(TimeDayOfWeek(dt)==0 && sign==-1) dt -= sign*2*24*60*60;
  if(TimeDayOfWeek(dt)==6 && sign==-1) dt -= sign*24*60*60;
  return dt;
}

void TradingSessions::setSessionMinMax(Enum_Sessions ts = NULL) {
  Print("setSessionMinMax() Entered");
  //Debug(__FUNCTION__,__LINE__,"Entered");
  if(!ts) ts = tradingSession;

  datetime start = getNextSessionStart(ts);   // getStartTime(ts);
  datetime end = getNextSessionEnd(ts);       // getEndTime(ts);
  
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

bool TradingSessions::isSOD(datetime t=0) {
  if(t==0) t = TimeCurrent();
  t -= local2serverOffset;      // convert to server time
  //Print("isSOD:  ",t," == ",startOfDay);
  if(t >= startOfDay) {
    startOfDay = addDay(startOfDay);
    dayBarNumber = 0;
    newDayBar = true;
    Print("Start of day bar");
    return true;
  }
  return(false);
}

bool TradingSessions::isEOD(datetime t=0) {
  if(t==0) t = TimeCurrent();
  t -= local2serverOffset;      // convert to server time
  //Print("isEOD:  ",t," == ",endOfDay);
  if(t >= endOfDay) {
    endOfDay = addDay(endOfDay);
    Print("End of day bar");
    return true;
  }
  return false;
}

bool TradingSessions::isSOS(datetime t=0) {
  if(t==0) t = TimeCurrent();
  //Print("a isSOS:  ",t," == ",nextStartTradeWindow);
  t -= local2serverOffset;      // convert to local time
  //Print("b isSOS:  ",t," == ",nextStartTradeWindow);
  if(t == nextStartTradeWindow) {
    nextStartTradeWindow = addDay(nextStartTradeWindow);
    Print("Start of session bar");
    return true;
  }
  return(false);
}

bool TradingSessions::isEOS(datetime t=0) {
  if(t==0) t = TimeCurrent();
  t -= local2serverOffset;      // convert to server time
  if(t >= nextEndTradeWindow) {
    nextEndTradeWindow = addDay(nextEndTradeWindow);
    Print("End of session bar");
    return true;
  }
  return(false);
}

// local time of next session start
datetime TradingSessions::getStartTime(Enum_Sessions ts) {
  datetime rtn = datetime((int)today0time() + int(LocalTime[season][ts][Start]*60*60));
  rtn = addDay(rtn);
  return(rtn);
}

// local time of next session end
datetime TradingSessions::getEndTime(Enum_Sessions ts) {
  datetime rtn = datetime((int)today0time() + int(LocalTime[season][ts][End]*60*60));
  rtn = addDay(rtn);
  return(rtn);
}

datetime TradingSessions::getNextSessionStart(Enum_Sessions ts, datetime t=0) {
  if(t==0) t = TimeCurrent();
  datetime rtn = datetime((int)today0time() + int(LocalTime[season][ts][Start]*60*60));
  if(rtn>t) rtn=addDay(rtn);
  return rtn;
}

datetime TradingSessions::getNextSessionEnd(Enum_Sessions ts, datetime t=0) {
  if(t==0) t = TimeCurrent();
  datetime rtn = datetime((int)today0time() + int(LocalTime[season][ts][End]*60*60));
  if(rtn>t) rtn=addDay(rtn);
  if(rtn<getNextSessionStart(ts,t)) rtn=addDay(rtn);
  return rtn;
}

datetime TradingSessions::sessionStartTime(Enum_TIME_ZONES tz, int sessionShift=0) {
  //datetime dt = getNextSessionStart(ts);
  return (datetime)(nextStartTradeWindow+getTZadj(tz)+sessionShift*24*60*60);
}

datetime TradingSessions::sessionEndTime(Enum_TIME_ZONES tz, int sessionShift=0) {
  return (datetime)(nextEndTradeWindow+getTZadj(tz)+sessionShift*24*60*60);
}

void TradingSessions::onNewBar(datetime barStart) {
  dayBarNumber++;
  if(isSOD(barStart)) {
    newDayBar = true;
  }
  if(isSOS(barStart)) {
    newSessionBar = true;
    inSession = true;
  }
  if(isEOS(barStart))
    inSession = false;
  if(inSession)
    sessionBarNumber++;
  else
    sessionBarNumber = 0;
}

void TradingSessions::closeOfBar() {
  newDayBar = false;
  newSessionBar = false;
}
