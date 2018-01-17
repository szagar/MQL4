//+------------------------------------------------------------------+
//|                                                        zts01.mq4 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict

#include <zts\logger.mqh>
#include <zts\common.mqh>

string f1(){return("########");}

extern string commentString_1 = "*****************************************";
extern string commentString_2 = __FILE__;
extern bool Testing = false;
extern Enum_LogLevels LogLevel = LogInfo;
extern bool GoLong = true;
extern bool GoShort = false;
extern int Slippage=5;
extern double MinReward2RiskRatio = 1.5;
extern string commentString_3 = "*****************************************";

#include <zts\zts05.mqh>
#include <zts\stats_eod.mqh>
#include <zts\TradingSessions.mqh>

string Prefix="ZTS_";
string Version="0.001";
string TextFont="Verdana";
color TextColor=Goldenrod;

Robo *robo;
TradingSessions *session;

datetime endOfDay;
datetime startOfDay;
datetime now;

int OnInit() {
  //EventSetTimer(60);
  robo = new Robo();
  session = new TradingSessions();
  
  robo.OnInit();
  
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;
  endOfDay = session.endOfDay;             //StructToTime(dtStruct) + 17*60*60;         // 5pm NY
  startOfDay = session.startOfDay;         //StructToTime(dtStruct) + 9*60*60;;       // 9am NY
  Info("Day start to end: "+string(startOfDay)+" - "+string(string(endOfDay)));

  DrawSystemStatus();

  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  EventKillTimer();
  robo.OnDeinit();
  if (CheckPointer(robo) == POINTER_DYNAMIC) delete robo;
  if (CheckPointer(session) == POINTER_DYNAMIC) delete session;
}

void OnTick() {
  now = TimeCurrent();
  robo.OnTick();   
  //Info("Tick: "+TimeLocal()+"  Current: "+TimeCurrent()+"  GMT:"+TimeGMT()+"  Time[0]:"+Time[0]);
  if(isNewBar()) {
    //Info(TimeToString(Time[0]));
    Debug("===> New Bar");
    robo.OnNewBar();     // tradeWindow());
    if(isEOD()) {
      robo.cleanUpEOD();
      string fname;
      fname = __FILE__;
      StringReplace(fname,".mq4","_eodStats.csv");
      Debug("fname is "+fname);
      StatsEndOfDay(fname);
      cleanUpEOD();
    }
    if(isSOD()) {
      robo.startOfDay();
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

bool isEOD() {
  if(now >= endOfDay) {
    endOfDay = session.addDay(endOfDay);
    Info("EOD bar");
    return(true);
  }
  return(false);
}

bool isSOD() {
  if(now >= startOfDay) {
    startOfDay = session.addDay(startOfDay);
    dayBarNumber = 1;
      Info("SOD bar");
    return true;
  }
  return(false);
}

void cleanUpEOD() {
}

//void startOfDay() {
//}

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

