//+------------------------------------------------------------------+
//|                                                        zts01.mq4 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict

extern string General = "=== " + __FILE__ + " ===";
extern bool Testing = false;
extern int Tbd = 1;
extern bool GoLong = true;
extern bool GoShort = false;

//#include <zts\common.mqh>
#include <zts\zts04.mqh>
#include <zts\stats_eod.mqh>
#include <zts\TradingSessions.mqh>

string Prefix="ZTS_";
string Version="0.001";
string TextFont="Verdana";
color TextColor=Goldenrod;

Robo *robo;
TradingSessions *session;

//datetime endOfDayServer;
//datetime startOfDayServer;
datetime endOfDayLocal;
datetime startOfDayLocal;
datetime nowLocal;

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
  //endOfDayServer = StructToTime(dtStruct) + 24*60*60;
  //startOfDayServer = StructToTime(dtStruct);
  //Info("Server Day start to end: "+string(startOfDayServer)+" - "+string(endOfDayServer));

  //endOfDayLocal = StructToTime(dtStruct) + 17*60*60;         // 5pm NY
  //startOfDayLocal = StructToTime(dtStruct) + 9*60*60;;       // 9am NY
  //Info("Local Day start to end 1: "+string(startOfDayLocal)+" - "+string(string(endOfDayLocal)));

  endOfDayLocal = session.endOfDayLocal;             //StructToTime(dtStruct) + 17*60*60;         // 5pm NY
  startOfDayLocal = session.startOfDayLocal;         //StructToTime(dtStruct) + 9*60*60;;       // 9am NY
  Info("Local Day start to end: "+string(startOfDayLocal)+" - "+string(string(endOfDayLocal)));

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
  nowLocal = TimeLocal();
  //robo.OnTick();   
  //Info("Tick: Local: "+TimeLocal()+"  Current: "+TimeCurrent()+"  GMT:"+TimeGMT()+"  Time[0]:"+Time[0]);
  if(isNewBar()) {
    //Info(TimeToString(Time[0]));
    Debug("===> New Bar");
    robo.OnNewBar();     // tradeWindow());
    if(isLocalEOD()) {
      //robo.cleanUpEOD();
      string fname;
      fname = __FILE__;
      StringReplace(fname,".mq4","_eodStats.csv");
      Debug("fname is "+fname);
      StatsEndOfDay(fname);
      cleanUpEOD();
    }
    if(isLocalSOD()) {
      //robo.startOfDay();
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
    endOfDayLocal = session.addDay(endOfDayLocal);
    Info("Local EOD bar");
    Info("New Local EOD: "+string(endOfDayLocal));
    return(true);
  }
  return(false);
}

bool isLocalSOD() {
  if(nowLocal >= startOfDayLocal) {
    startOfDayLocal = session.addDay(startOfDayLocal);
    robo.dayBarNumber = 1;
      Info("Local SOD bar");
      Info("New Local SOD: "+string(startOfDayLocal));
    return true;
  }
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

