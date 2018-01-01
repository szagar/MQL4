//+------------------------------------------------------------------+
//|                                                        zts01.mq4 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict

extern string General = "=== " + __FILE__ + " ===";
extern int Tbd = 1;
extern bool GoLong = true;
extern bool GoShort = false;

#include <zts\zts03.mqh>
#include <zts\stats_eod.mqh>

string Prefix="ZTS_";
string Version="0.001";
string TextFont="Verdana";
color TextColor=Goldenrod;

Robo *robo;

datetime endOfDayServer;
datetime startOfDayServer;
datetime endOfDayLocal;
datetime startOfDayLocal;
datetime nowLocal;

int OnInit() {
  //EventSetTimer(60);
  robo = new Robo();
  robo.OnInit();
  
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;
  endOfDayServer = StructToTime(dtStruct) + 24*60*60;
  startOfDayServer = StructToTime(dtStruct);
  endOfDayLocal = StructToTime(dtStruct) + 17*60*60;         // 5pm NY
  startOfDayLocal = StructToTime(dtStruct) + 9*60*60;;       // 9am NY
  Alert("endOfDayServer = " + string(endOfDayServer));
  Alert("startOfDayServer = " + string(startOfDayServer));
  Alert("endOfDayLocal = " + string(endOfDayLocal));
  Alert("startOfDayLocal = " + string(startOfDayLocal));
  
  //robo.addSetup(1);
  
  DrawSystemStatus();

  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  EventKillTimer();
  robo.OnDeinit();
  if (CheckPointer(robo) == POINTER_DYNAMIC) delete robo;

}

void OnTick() {
  nowLocal = TimeLocal();
  robo.OnTick();   
  if(isNewBar()) {
    Debug("===> New Bar");
    robo.OnNewBar(tradeWindow());
    if(isLocalEOD()) {
      robo.cleanUpEOD();
      string fname;
      fname = __FILE__;
      StringReplace(fname,".mq4","_eodStats.csv");
      Alert("fname is "+fname);
      StatsEndOfDay(fname);
      cleanUpEOD();
    }
    if(isLocalSOD()) {
      robo.startOfDay();
      startOfDay();
    }
  }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {
  double ret=0.0;
  return(ret);
}

bool isLocalEOD() {
  if(nowLocal >= endOfDayLocal) {
    endOfDayLocal += 24*60*60;
    startOfDayLocal += 24*60*60;
    Alert("New Local EOD: "+string(endOfDayLocal));
    Alert("New Local SOD: "+string(startOfDayLocal));
    return(true);
  }
  return(false);
}

bool isLocalSOD() {
  return(false);
}

void cleanUpEOD() {
}

void startOfDay() {
}

void DrawSystemStatus() {
  string name;
  name = StringConcatenate(Prefix,"Version");
  
  ObjectCreate(name,OBJ_LABEL,0,0,0);
  string text = "ver:"+Version+" / offset:"+string(TimeGMTOffset()/60/60);
  ObjectSetText(name,text,8,TextFont,TextColor);
  ObjectSet(name,OBJPROP_CORNER,2);
  ObjectSet(name,OBJPROP_XDISTANCE,5);
  ObjectSet(name,OBJPROP_YDISTANCE,2);
} 

bool isNewBar() {
  static datetime time0;
  //Debug("NewBar: time0="+time0);
  //Debug("NewBar: Time[0]="+Time[0]);
  if(Time[0] == time0) return false;
  time0 = Time[0];
  return true;
}

bool tradeWindow() {
   //if(GMToffset >= 24) GMToffset = 0;//Valid Offset range is from 0 to 23
   //StartTime  = HourStart + GMToffset; 
   //if(StartTime > 23) StartTime =HourStart + GMToffset - 24;   
   //StopTime  = HourStop + GMToffset; 
   //if(StopTime > 23) StopTime = 0;
   //Comment( "GMT: ",GMToffset, "           Start: ",StartTime , "          Stop: ",StopTime);
   datetime StartTime = TimeHour(robo.startTradingSession_GMT);
   datetime StopTime = TimeHour(robo.endTradingSession_GMT);
   Print("GMT: ",StartTime," --> ",TimeCurrent()," --> ",StopTime);
   Debug("1");
   int currentHour = TimeHour(TimeCurrent());
   Debug("if ( ("+string(StartTime)+" < "+string(StopTime)+") && (("+string(currentHour)+" < "+string(StartTime)+")  || ("+string(currentHour)+" >= "+string(StopTime)+")) ) return (FALSE)");
   if ( (StartTime < StopTime)  && (currentHour < StartTime  || currentHour >= StopTime) ) return (FALSE);
   Debug("2");
   if ( (StartTime > StopTime)  && (TimeHour(TimeCurrent()) < StartTime)  && (TimeHour(TimeCurrent()) >= StopTime) ) return (FALSE);
   Debug("3");
   if (StopTime  == 0.0) StopTime  = 24;
   Debug("4");
   if (Hour() == StopTime  - 1.0 && Minute() >= 59) return (FALSE);
   Debug("5");
return (TRUE);
}