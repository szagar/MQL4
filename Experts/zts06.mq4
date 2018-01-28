//+------------------------------------------------------------------+
//|                                                        zts06.mq4 |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict

#include <dev\logger.mqh>
#include <dev\common.mqh>

#include <dev\TradingSessions.mqh>

extern string commentString_1 = "";  //*****************************************
extern string commentString_2 = "";  //zts06
extern bool Testing = false;               //>> Testing ?
extern Enum_LogLevels LogLevel = LogInfo;  //>> Log Level
extern bool GoLong = true;                 //>> Go Long ?
extern bool GoShort = false;               //>> Go Short ?
extern Enum_Sessions TradingSession = All; //>> Trading Session
extern bool ReverseLongShort = false;      //>> Reverse Long/Short Criteria
extern int Slippage=5;                     //>> Slippage in pips 
extern double MinReward2RiskRatio = 1.5;   //>> Min Reward / Risk 
extern double PercentRiskPerPosition=0.5; //>> Percent to risk per position
//extern string commentString_3 = "";      //*****************************************

#include <dev\robo1.mqh>
//#include <dev\stats_eod.mqh>

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
  setSomeConstants();
  session = new TradingSessions(TradingSession);
  session.showAllSessions("local");
  robo = new Robo(session);
  
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
    Debug(__FUNCTION__,__LINE__,"===> New Bar");
    robo.OnNewBar();     // tradeWindow());
    if(isEOD()) {
      robo.cleanUpEOD();
      string fname;
      fname = __FILE__;
      StringReplace(fname,".mq4","_eodStats.csv");
      Debug(__FUNCTION__,__LINE__,"fname is "+fname);
      //StatsEndOfDay(fname);
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
    Info("SOD bar");
    return true;
  }
  return(false);
}

void cleanUpEOD() {
  Info("EOD cleanup");
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
