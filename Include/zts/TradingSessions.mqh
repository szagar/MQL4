//+------------------------------------------------------------------+
//|                                              TradingSessions.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Enum_Sessions{
  tbd=0,
   Asia=1,
   London=2,
   NewYork=3,
   NYSE=4,
   LondonClose=5
 };

class TradingSessions {
private:
  Enum_Sessions tradingSession;
  int server2gmtOffset;
  int server2gmtOffsetHrs;
  int local2gmtOffset;
  int local2gmtOffsetHrs;
  int local2serverOffset;
  int local2serverOffsetHrs;

  datetime SessionTimes_Start[6];
  datetime SessionTimes_End[6];

public:
  TradingSessions(Enum_Sessions _tradingSession=NewYork);
  ~TradingSessions();
  
  void setSession(Enum_Sessions);
  bool tradeWindow(Enum_Sessions);
  string showSession(bool);
  
  datetime startTradingDay_Server;
  datetime endTradingDay_Server;
  
  datetime startTradingSession_Server;
  datetime endTradingSession_Server;
};

TradingSessions::TradingSessions(Enum_Sessions _tradingSession=NewYork) {
  tradingSession= _tradingSession;
  server2gmtOffset = int(TimeCurrent()-TimeGMT());
  server2gmtOffsetHrs = int(server2gmtOffset / (60*60));
  local2gmtOffset = TimeGMTOffset();
  local2gmtOffsetHrs = int(local2gmtOffset / (60*60));
  local2serverOffset = int(TimeCurrent() - TimeLocal());
  local2serverOffsetHrs = int(local2serverOffset / (60*60));
  
  Alert(__FUNCTION__+": SanityCheck 1:  server2gmtOffsetHrs  ="+string(server2gmtOffsetHrs));
  Alert(__FUNCTION__+": SanityCheck 2:  local2gmtOffsetHrs   ="+string(local2gmtOffsetHrs));
  Alert(__FUNCTION__+": SanityCheck 3:  local2serverOffsetHrs="+string(local2serverOffsetHrs));
  Alert(__FUNCTION__+": SanityCheck 4:  "+string(server2gmtOffsetHrs)+" + "+string(local2gmtOffsetHrs)+" = "+string(local2serverOffsetHrs));
  
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;

  startTradingDay_Server = StructToTime(dtStruct);
  endTradingDay_Server = StructToTime(dtStruct) + 24*60*60;;

  /*                  EST                  GMT              */
  /*    Asia          6pm - 3am            11pm - 8am       */
  /*    London        3am - 12pm           8am - 5pm        */
  /*    NewYork       8am - 5pm            1pm - 10pm       */
  /*    NYSE          9.5am - 4pm          2.5pm - 9pm      */
  /*    LondonClose   11am - 1pm           4pm - 6pm        */
  SessionTimes_Start[Asia]    = StructToTime(dtStruct) + (3)*60*60;
  SessionTimes_End[Asia]      = StructToTime(dtStruct) + int((8.5)*60*60);
  SessionTimes_Start[London]  = StructToTime(dtStruct) + (3)*60*60;
  SessionTimes_End[London]    = StructToTime(dtStruct) + (local2serverOffsetHrs+9)*60*60;
  SessionTimes_Start[NewYork] = StructToTime(dtStruct) + (local2serverOffsetHrs+8)*60*60;
  SessionTimes_End[NewYork]   = StructToTime(dtStruct) + (local2serverOffsetHrs+17)*60*60;
  SessionTimes_Start[NewYork] = StructToTime(dtStruct) + int(local2serverOffsetHrs+9.5)*60*60;
  SessionTimes_End[NewYork]   = StructToTime(dtStruct) + (local2serverOffsetHrs+16)*60*60;
  SessionTimes_Start[LondonClose] = StructToTime(dtStruct) + (local2serverOffsetHrs+9)*60*60;
  SessionTimes_End[LondonClose]   = StructToTime(dtStruct) + (local2serverOffsetHrs+16)*60*60;

  startTradingDay_Server = StructToTime(dtStruct);
  endTradingDay_Server = StructToTime(dtStruct) + 24*60*60;;
}

TradingSessions::~TradingSessions() {
}
  
void TradingSessions::setSession(Enum_Sessions ts) {
  tradingSession = ts;
  startTradingSession_Server = SessionTimes_Start[tradingSession];
  endTradingSession_Server = SessionTimes_End[tradingSession];
}

string TradingSessions::showSession(bool detail=false) {
  string rtn = EnumToString(tradingSession);
  if(detail)
    rtn += ":  "+string(startTradingSession_Server)+" - "+string(endTradingDay_Server);
  return rtn;
}

/*
  //long local2serverOffset = int(TimeCurrent() - TimeLocal());
  //int local2serverOffsetHrs = int(local2serverOffset / (60*60));
  //Alert("Offset Should be 7 hrs.... "+string(local2serverOffsetHrs));
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;
  
  startTradingSession_Server = StructToTime(dtStruct) + (local2serverOffsetHrs+9)*60*60;
  endTradingSession_Server = StructToTime(dtStruct) + (local2serverOffsetHrs+16)*60*60;
  
  switch(tradingSession) {
    case 1:   // London 
      startTradingSession_Server = StructToTime(dtStruct) + (local2serverOffsetHrs+9)*60*60;
      endTradingSession_Server = StructToTime(dtStruct) + (local2serverOffsetHrs+16)*60*60;
      break;
    case 2:   // New York
      startTradingSession_Server = StructToTime(dtStruct) + (local2serverOffsetHrs+9)*60*60;
      endTradingSession_Server = StructToTime(dtStruct) + (local2serverOffsetHrs+16)*60*60;
      break;
    case 3:   // Asia
      startTradingSession_Server = StructToTime(dtStruct) + (3)*60*60;
      endTradingSession_Server = StructToTime(dtStruct) + int((8.5)*60*60);
      break;
    case 4:   // London close
      startTradingSession_Server = StructToTime(dtStruct) + (local2serverOffsetHrs+9)*60*60;
      endTradingSession_Server = StructToTime(dtStruct) + (local2serverOffsetHrs+16)*60*60;
      break;
    default:
      Alert(__FUNCTION__+": sesson ID unknown.");
  }
}
*/

bool TradingSessions::tradeWindow(Enum_Sessions ts = tbd) {
  int startTime;
  int stopTime;
  if(ts == tbd) {
    startTime = TimeHour(SessionTimes_Start[tradingSession]);
    stopTime = TimeHour(SessionTimes_End[tradingSession]);
  } else {
    startTime = TimeHour(SessionTimes_Start[ts]);
    stopTime = TimeHour(SessionTimes_End[ts]);
  }  
  int currentHour = TimeHour(TimeCurrent());
  if ( (startTime < stopTime)  && (currentHour < startTime  || currentHour >= stopTime) ) return (FALSE);
  if ( (startTime > stopTime)  && (TimeHour(TimeCurrent()) < startTime)  && (TimeHour(TimeCurrent()) >= stopTime) ) return (FALSE);
  if (stopTime  == 0.0) stopTime  = 24;
  if (Hour() == stopTime  - 1.0 && Minute() >= 59) return (FALSE);
  return (TRUE);
}


