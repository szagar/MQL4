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

#include <dev/logger.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

  double LocalOffsets[NumSeasons][NumSessions][2];
  //Enum_Sessions session;
  Enum_Seasons season;
  
  datetime SessionTimes_Start[NumSessions];
  datetime SessionTimes_End[NumSessions];

  void initOffsets();
public:
  TradingSessions(Enum_Sessions _tradingSession=NewYork, Enum_Seasons _season=Winter);
  ~TradingSessions();

  void initSessionTimes();
  
  datetime addDay(datetime);
  void setSession(Enum_Sessions);
  void setSessionMinMax();
  datetime previousSessionStart(datetime t=0);
  bool tradeWindow(Enum_Sessions);
  bool tradeWindow(datetime ts, Enum_Sessions ts);

  bool tradeWindowHr(Enum_Sessions);
  string showSession(bool);
  void showAllSessions(string);
  
  datetime startTimeForSession(Enum_Sessions,string);
  datetime endTimeForSession(Enum_Sessions,string);
  
  Enum_Sessions tradingSession;
  double hiPrice, loPrice;
  datetime hiPriceDT,loPriceDT;

  datetime startOfDay;
  datetime endOfDay;
  
  datetime startTradingSession_Server;
  datetime endTradingSession_Server;
};

TradingSessions::TradingSessions(Enum_Sessions _tradingSession=NewYork, Enum_Seasons _season=Winter) {
  Info("TimeCurrent() = "+string(TimeCurrent()));
  Info("TimeLocal() = "+string(TimeLocal()));
  tradingSession= _tradingSession;
  season = _season;
  datetime local,current,gmt;

  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;
  

  if(Testing) {
    gmt = StructToTime(dtStruct);
    local = gmt - 5*60*60;
    current = gmt + 2*60*60;
  } else {
    local = TimeLocal();
    current = TimeCurrent();
    gmt = TimeGMT();
  }
  gmt2serverOffset = int(current-gmt);  //    server = GMT + 2
  local2gmtOffset = int(gmt - local);  //TimeGMTOffset();   local = GMT - 5
  local2serverOffset = int(current - local);

  gmt2serverOffsetHrs = int(gmt2serverOffset / (60*60));
  local2gmtOffsetHrs = int(local2gmtOffset / (60*60));
  local2serverOffsetHrs = int(local2serverOffset / (60*60));
  
  Info("SanityCheck:  gmt2serverOffsetHrs  ="+string(gmt2serverOffsetHrs));
  Info("SanityCheck:  local2gmtOffsetHrs      ="+string(local2gmtOffsetHrs));
  Info("SanityCheck:  local2serverOffsetHrs="+string(local2serverOffsetHrs));
  Info("SanityCheck:  "+string(local2gmtOffsetHrs)+" + "+string(gmt2serverOffsetHrs)+" = "+string(local2serverOffsetHrs));
  
  startOfDay = StructToTime(dtStruct) + 1*60*60;;
    endOfDay = local2serverOffset + 17;

  initSessionTimes();
  
  setSession(tradingSession);
}

void TradingSessions::initSessionTimes() {
  /*                  EST                  GMT              */
  /*    Asia          6pm - 3am            11pm - 8am       */
  /*    London        3am - 12pm           8am - 5pm        */
  /*    NewYork       8am - 5pm            1pm - 10pm       */
  /*    NYSE          9.5am - 4pm          2.5pm - 9pm      */
  /*    LondonClose   11am - 1pm           4pm - 6pm        */
  initOffsets();    //  GMT zone
  
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;

  SessionTimes_Start[Asia]    = StructToTime(dtStruct) + int(LocalOffsets[season][Asia][Start]*60*60);
  SessionTimes_End[Asia]      = StructToTime(dtStruct) + int(LocalOffsets[season][Asia][End]*60*60);
  SessionTimes_Start[AsiaLast1] = StructToTime(dtStruct) + int(LocalOffsets[season][AsiaLast1][Start]*60*60);
  SessionTimes_End[AsiaLast1]   = StructToTime(dtStruct) + int(LocalOffsets[season][AsiaLast1][End]*60*60);
  SessionTimes_Start[London]  = StructToTime(dtStruct) + int(LocalOffsets[season][London][Start]*60*60);
  SessionTimes_End[London]    = StructToTime(dtStruct) + int(LocalOffsets[season][London][End]*60*60);
  SessionTimes_Start[NewYork] = StructToTime(dtStruct) + int(LocalOffsets[season][NewYork][Start]*60*60);
  SessionTimes_End[NewYork]   = StructToTime(dtStruct) + int(LocalOffsets[season][NewYork][End]*60*60);
  Debug(__FUNCTION__,__LINE__,"StructToTime(dtStruct) = "+TimeToString(StructToTime(dtStruct)));
  Debug(__FUNCTION__,__LINE__,"LocalOffsets[season][NYSE][Start] = "+string(LocalOffsets[season][NYSE][Start]));
  Debug(__FUNCTION__,__LINE__,"LocalOffsets[season][NYSE][Start]*60*60 = "+string(LocalOffsets[season][NYSE][Start]*60*60));
  SessionTimes_Start[NYSE] = datetime(StructToTime(dtStruct) + LocalOffsets[season][NYSE][Start]*60*60);
  Debug(__FUNCTION__,__LINE__,"SessionTimes_Start[NYSE] = "+string(SessionTimes_Start[NYSE]));
  SessionTimes_End[NYSE]   = StructToTime(dtStruct) + int(LocalOffsets[season][NYSE][End]*60*60);
  SessionTimes_Start[NYlast1] = StructToTime(dtStruct) + int(LocalOffsets[season][NYlast1][Start]*60*60);
  SessionTimes_End[NYlast1]   = StructToTime(dtStruct) + int(LocalOffsets[season][NYlast1][End]*60*60);
  SessionTimes_Start[LondonClose] = StructToTime(dtStruct) + int(LocalOffsets[season][LondonClose][Start]*60*60);
  SessionTimes_End[LondonClose]   = StructToTime(dtStruct) + int(LocalOffsets[season][LondonClose][End]*60*60);

  //startTradingDay_Server = StructToTime(dtStruct);
  //endTradingDay_Server = StructToTime(dtStruct) + 24*60*60;
}

TradingSessions::~TradingSessions() {
}
  
void TradingSessions::initOffsets() {
  // GMT based !!
  season = Winter;
  LocalOffsets[season][Asia][Start] = 0;
  LocalOffsets[season][Asia][End]   = 9;
  LocalOffsets[season][AsiaLast1][Start] = 5;
  LocalOffsets[season][AsiaLast1][End]   = 6;
  LocalOffsets[season][London][Start] = 8;
  LocalOffsets[season][London][End]   = 17;
  LocalOffsets[season][NewYork][Start] = 13;
  LocalOffsets[season][NewYork][End]   = 21;
  LocalOffsets[season][NYSE][Start] = 14.5;
  LocalOffsets[season][NYSE][End]   = 21;
  LocalOffsets[season][NYlast1][Start] = 20;
  LocalOffsets[season][NYlast1][End]   = 21;
  LocalOffsets[season][LondonClose][Start] = 15;
  LocalOffsets[season][LondonClose][End]   = 17;
}

void TradingSessions::setSession(Enum_Sessions ts) {
  tradingSession = ts;
  Debug(__FUNCTION__,__LINE__,"session:"+EnumToString(ts));
  startTradingSession_Server = SessionTimes_Start[tradingSession] + gmt2serverOffset;
  endTradingSession_Server = SessionTimes_End[tradingSession] + gmt2serverOffset;
  Debug(__FUNCTION__,__LINE__,"server:"+TimeToStr(startTradingSession_Server)+" - "+TimeToStr(endTradingSession_Server));  
}

string TradingSessions::showSession(bool detail=false) {
  string rtn = EnumToString(tradingSession);
  if(detail)
    rtn += ":  "+string(startTradingSession_Server)+" - "+string(endTradingSession_Server);
    
  return rtn;
}

void TradingSessions::showAllSessions(string tz = "server") {
  Debug(__FUNCTION__,__LINE__,"Entered");
  int adj = 0;
  string str;
  if(StringCompare(tz,"local",false)==0)
    adj = -local2serverOffset;
  if(StringCompare(tz,"gmt",false)==0)
    adj = -gmt2serverOffset;
  Enum_Sessions save = tradingSession;
  Info(tz+" ("+string(adj/60/60)+")");
  for(Enum_Sessions i=0; i<EnumLast; i++ ) {
    setSession(i);
    str = StringFormat("Session: %-10s: %s - %s",EnumToString(i),TimeToStr(startTradingSession_Server+adj),TimeToString(endTradingSession_Server+adj));
    Info(str);
  }
  setSession(save);
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

bool TradingSessions::tradeWindowHr(Enum_Sessions ts = tbd) {
  int startTime;
  int stopTime;
  if(ts == All) return true;
  if(ts == tbd) {
    startTime = TimeHour(SessionTimes_Start[tradingSession] + gmt2serverOffsetHrs);
    stopTime = TimeHour(SessionTimes_End[tradingSession] + gmt2serverOffsetHrs);
  } else {
    startTime = TimeHour(SessionTimes_Start[ts] + gmt2serverOffsetHrs);
    stopTime = TimeHour(SessionTimes_End[ts] + gmt2serverOffsetHrs);
  }  
  //Info("tradeWindow: "+startTime+" - "+stopTime);

  int currentHour = TimeHour(TimeCurrent());
  if ( (startTime < stopTime)  && (currentHour < startTime  || currentHour >= stopTime) ) return (FALSE);
  if ( (startTime > stopTime)  && (currentHour < startTime)  && (currentHour >= stopTime) ) return (FALSE);
  if (stopTime  == 0.0) stopTime  = 24;
  if (Hour() == stopTime  - 1.0 && Minute() >= 59) return (FALSE);
  return (TRUE);
}

/**
bool TradingSessions::tradeWindow(datetime t, Enum_Sessions ts = tbd) {
  int startTime;
  int startMinute;
  int stopTime;
  if(ts == tbd) {
    startTime = TimeHour(SessionTimes_Start[tradingSession] + gmt2serverOffsetHrs);
    startMinute = TimeMinute(SessionTimes_Start[tradingSession]);   // + gmt2serverOffset);
    stopTime = TimeHour(SessionTimes_End[tradingSession] + gmt2serverOffsetHrs);
  } else {
    startTime = TimeHour(SessionTimes_Start[ts] + gmt2serverOffsetHrs);
    startMinute = TimeMinute(SessionTimes_Start[ts]);   // + gmt2serverOffset);
    stopTime = TimeHour(SessionTimes_End[ts] + gmt2serverOffsetHrs);
  }  
  int currentHour = TimeHour(t);
  int currentMinute = TimeMinute(t);
  if ( (startTime < stopTime)  && (currentHour < startTime  || currentHour >= stopTime) ) return (FALSE);
  if ( (startTime < stopTime)  && (currentHour < startTime  ||
                                   (currentHour == startTime && currentMinute < startMinute) || 
                                   currentHour >= stopTime) ) return (FALSE);
  if ( (startTime > stopTime)  && (currentHour < startTime)  && (currentHour >= stopTime) ) return (FALSE);
  if (stopTime  == 0.0) stopTime  = 24;
  if (Hour() == stopTime  - 1.0 && Minute() >= 59) return (FALSE);
  return (TRUE);
}
**/

bool TradingSessions::tradeWindow(Enum_Sessions ts = tbd) {
  if(ts == tbd) ts = tradingSession;
  int startTime;
  int startMinute;
  int stopTime;
  //if(ts == tbd) {
  //  startTime = TimeHour(SessionTimes_Start[tradingSession] + gmt2serverOffsetHrs);
  //  startMinute = TimeMinute(SessionTimes_Start[tradingSession]);   // + gmt2serverOffset);
  //  stopTime = TimeHour(SessionTimes_End[tradingSession] + gmt2serverOffsetHrs);
  //} else {
    startTime = TimeHour(SessionTimes_Start[ts] + gmt2serverOffsetHrs);
    startMinute = TimeMinute(SessionTimes_Start[ts]);   // + gmt2serverOffset);
    stopTime = TimeHour(SessionTimes_End[ts] + gmt2serverOffsetHrs);
  //}  
  //Info("tradeWindow: "+startTime+" - "+stopTime);

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

datetime TradingSessions::startTimeForSession(Enum_Sessions thisSession,string tz="Server") {
  //initSessionTimes();
  if(StringCompare(tz,"Server")==0)
    return SessionTimes_Start[thisSession] + gmt2serverOffset;
  return NULL;
}

datetime TradingSessions::endTimeForSession(Enum_Sessions thisSession,string tz="Server") {
  //initSessionTimes();
  if(StringCompare(tz,"Server")==0)
    return SessionTimes_End[thisSession] + gmt2serverOffset;
  return NULL;
}