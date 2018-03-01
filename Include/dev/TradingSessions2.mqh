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

extern int Local2GMT_hours = -5;
extern int Server2GMT_hours = 2;

#include <dev/logger.mqh>

#define NumSessions 9
enum Enum_Sessions{
  tbd=0,
   All,
   Asia,
   AsiaLast1,
   London,
   NewYork,
   NYSE,
   NYlast1,
   LondonClose,
   EnumLast
 };
enum Enum_TZ {Server, Local, GMT};
enum Enum_SessionSegments {
  all=0,
  first=1,
  second=2,
  third=3
};
#define NumSeasons 2
enum Enum_Seasons{ Winter, Summer };

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

  double LocalTime[NumSeasons][NumSessions][2];
  //Enum_Sessions session;
  Enum_Seasons season;
  
  datetime SessionTimes_Start[NumSessions];
  datetime SessionTimes_End[NumSessions];

  void initOffsets();
  datetime today0time();
  int tzAdjustment(Enum_TZ);
  datetime getStartTime(Enum_Sessions);
  datetime getEndTime(Enum_Sessions);

public:
  TradingSessions(Enum_Sessions _tradingSession=NewYork, Enum_Seasons _season=Winter);
  ~TradingSessions();

  void initSessionTimes();
  
  datetime addDay(datetime);
  void setSession(Enum_Sessions);
  void setSessionMinMax();
  datetime previousSessionStart(datetime t=0);

  bool tradeWindow(Enum_Sessions,Enum_SessionSegments);
  bool tradeWindow(datetime,Enum_Sessions);
  bool tradeWindowHr(Enum_Sessions,Enum_SessionSegments);
  
  string showSession(bool,Enum_TZ);
  string showAllSessions(Enum_TZ);

  bool isSOD(datetime);
  bool isSOS(datetime);
  
  datetime startTimeForSession(Enum_Sessions,Enum_TZ);
  datetime endTimeForSession(Enum_Sessions,Enum_TZ);
  
  Enum_Sessions tradingSession;
  double hiPrice, loPrice;
  datetime hiPriceDT,loPriceDT;

  datetime startOfDayLocal;
  datetime endOfDayLocal;
  
  datetime startTradingSession_Server;
  datetime endTradingSession_Server;
};

datetime TradingSessions::today0time() {
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;
  return StructToTime(dtStruct);
}

TradingSessions::TradingSessions(Enum_Sessions _tradingSession=NewYork, Enum_Seasons _season=Winter) {
  Info("TimeCurrent() = "+string(TimeCurrent()));
  Info("TimeLocal() = "+string(TimeLocal()));
  tradingSession= _tradingSession;
  season = _season;
  //datetime local,current,gmt;

  if(Testing) {
    gmt2serverOffsetHrs = Server2GMT_hours;
    local2gmtOffsetHrs  = Local2GMT_hours;
    local2serverOffsetHrs = Server2GMT_hours - Local2GMT_hours;
  } else {
    local2gmtOffsetHrs    = (int)((TimeLocal()-TimeGMT())/60/60);
    gmt2serverOffsetHrs   = (int)((TimeCurrent()-TimeGMT())/60/60);
    local2serverOffsetHrs = (int)((TimeCurrent() - TimeLocal())/60/60);
  }
  gmt2serverOffset   = gmt2serverOffsetHrs*60*60;
  local2gmtOffset    = local2gmtOffsetHrs*60*60;
  local2serverOffset = local2serverOffsetHrs*60*60;


  Info("SanityCheck:  gmt2serverOffset  ="+string(gmt2serverOffset));
  Info("SanityCheck:  local2gmtOffset   ="+string(local2gmtOffset));
  Info("SanityCheck:  local2serverOffset="+string(local2serverOffset));
  Info("SanityCheck:  "+string(gmt2serverOffset)+" - "+string(local2gmtOffset)+" = "+string(local2serverOffset));
  
  Info("SanityCheck:  gmt2serverOffsetHrs  ="+string(gmt2serverOffsetHrs));
  Info("SanityCheck:  local2gmtOffsetHrs      ="+string(local2gmtOffsetHrs));
  Info("SanityCheck:  local2serverOffsetHrs="+string(local2serverOffsetHrs));
  Info("SanityCheck:  "+string(gmt2serverOffsetHrs)+" - "+string(local2gmtOffsetHrs)+" = "+string(local2serverOffsetHrs));
  
  startOfDayLocal = today0time() + 1*60*60;;
    endOfDayLocal = today0time() + 17*60*60;

  initOffsets();
  setSession(tradingSession);
}

datetime TradingSessions::getStartTime(Enum_Sessions ts) {
  return today0time() + int(LocalTime[season][ts][Start]*60*60);
}

datetime TradingSessions::getEndTime(Enum_Sessions ts) {
  return today0time() + int(LocalTime[season][ts][End]*60*60);
}

void TradingSessions::initSessionTimes() {
  /*                  EST                  GMT              */
  /*    Asia          6pm - 3am            11pm - 8am       */
  /*    London        3am - 12pm           8am - 5pm        */
  /*    NewYork       8am - 5pm            1pm - 10pm       */
  /*    NYSE          9.5am - 4pm          2.5pm - 9pm      */
  /*    LondonClose   11am - 1pm           4pm - 6pm        */
  initOffsets();    //  GMT zone
}

TradingSessions::~TradingSessions() {
}
  
void TradingSessions::initOffsets() {
  // GMT based !!
  season = Winter;
  LocalTime[season][Asia][Start] = 19;
  LocalTime[season][Asia][End]   = 4;
  LocalTime[season][AsiaLast1][Start] = 3;
  LocalTime[season][AsiaLast1][End]   = 4;
  LocalTime[season][London][Start] = 3;
  LocalTime[season][London][End]   = 12;
  LocalTime[season][NewYork][Start] = 8;
  LocalTime[season][NewYork][End]   = 16;
  LocalTime[season][NYSE][Start] = 9.5;
  LocalTime[season][NYSE][End]   = 16;
  LocalTime[season][NYlast1][Start] = 15;
  LocalTime[season][NYlast1][End]   = 16;
  LocalTime[season][LondonClose][Start] = 11;
  LocalTime[season][LondonClose][End]   = 12;
}

void TradingSessions::setSession(Enum_Sessions ts) {
  tradingSession = ts;
  startTradingSession_Server = getStartTime(ts) + tzAdjustment(Server);
  endTradingSession_Server = getEndTime(ts) + tzAdjustment(Server);
}

string TradingSessions::showSession(bool detail=false,Enum_TZ tz = Server) {
  int adj = tzAdjustment(tz);
  string rtn = EnumToString(tradingSession)+"("+(string)adj+") ";
  if(detail)
    rtn += ":  "+string(getStartTime(tradingSession)+adj)+" - "+string(getEndTime(tradingSession)+adj);
  return rtn;
}

string TradingSessions::showAllSessions(Enum_TZ tz = Server) {
  string str;
  int adj = tzAdjustment(tz);
  Enum_Sessions save = tradingSession;
  for(Enum_Sessions i=0; i<EnumLast; i++ ) {
    setSession(i);
    str += StringFormat("Session: %-10s: %s - %s",
           EnumToString(i),TimeToStr(startTradingSession_Server+adj),
           TimeToString(endTradingSession_Server+adj));
    str += "\n";
  }
  setSession(save);
  return(str);
}

datetime TradingSessions::previousSessionStart(datetime t=0) {
  if(t==0) t = TimeCurrent();
  MqlDateTime dtStruct;
  TimeToStruct(t, dtStruct);
  dtStruct.hour = TimeHour(SessionTimes_Start[NYSE] + gmt2serverOffsetHrs);
  dtStruct.min = TimeMinute(SessionTimes_Start[NYSE]);
  dtStruct.sec = 0;
  return(StructToTime(dtStruct));
}

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
  int startTime,startMinute,stopTime;
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
  startMinute = TimeMinute(startTime);
  stopTime = TimeHour(stopTime);
  
  //startTime = TimeHour(SessionTimes_Start[ts] + gmt2serverOffsetHrs);
  //startMinute = TimeMinute(SessionTimes_Start[ts]);   // + gmt2serverOffset);
  //stopTime = TimeHour(SessionTimes_End[ts] + gmt2serverOffsetHrs);

  int currentHour = TimeHour(TimeCurrent());
  int currentMinute = TimeMinute(TimeCurrent());
  if ( (startTime < stopTime)  && (currentHour < startTime  || currentHour >= stopTime) ) return (FALSE);
  if ( (startTime < stopTime)  && (currentHour < startTime  ||
                                   (currentHour == startTime && currentMinute < startMinute) || 
                                   currentHour >= stopTime) ) return (FALSE);
  if ( (startTime > stopTime)  && (currentHour < startTime)  && (currentHour >= stopTime) ) return (FALSE);
  if (stopTime  == 0.0) stopTime  = 24;
  if (Hour() == stopTime  - 1.0 && Minute() >= 59) return (FALSE);
  return (TRUE);
}

datetime TradingSessions::addDay(datetime to) {
  Debug(__FUNCTION__,__LINE__,string(to)+" -> "+string(to + 24*60*60));
  return(to + 24*60*60);
}

void TradingSessions::setSessionMinMax() {
  Debug(__FUNCTION__,__LINE__,"Entered");

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

datetime TradingSessions::startTimeForSession(Enum_Sessions thisSession,Enum_TZ tz=Server) {
  if(tz==Server)
    return SessionTimes_Start[thisSession] + gmt2serverOffset;
  return NULL;
}

datetime TradingSessions::endTimeForSession(Enum_Sessions thisSession,Enum_TZ tz=Server) {
  if(tz==Server)
    return SessionTimes_End[thisSession] + gmt2serverOffset;
  return NULL;
}

bool TradingSessions::isSOD(datetime t=0) {
  if(t==0)
    t = TimeLocal();
  if(t >= startOfDayLocal) {
    //startOfDay = addDay(startOfDay);
    initSessionTimes();
    return true;
  }
  return(false);
}

bool TradingSessions::isSOS(datetime t=0) {
  if(t==0)
    t = TimeCurrent();
  initSessionTimes();
  if(t == startTimeForSession(tradingSession)) {
    //startOfDay = addDay(startOfDay);
    //initSessionTimes();
    return true;
  }
  return(false);
}

int TradingSessions::tzAdjustment(Enum_TZ tz) {
  if(tz==Server)
    return local2serverOffset;
  if(tz==Local)
    return 0;
  if(tz==GMT)
    return -local2gmtOffset;
  return 0;
}

