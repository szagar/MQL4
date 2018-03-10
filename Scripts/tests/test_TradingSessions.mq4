//+------------------------------------------------------------------+
//|                                         test_TradingSessions.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict
#property show_inputs

extern bool Testing=false;

#include <ATS\TradingSessions.mqh>
extern Enum_LogLevels LogLevel = LogDebug;    //>> Log Level

TradingSessions *obj;

void OnStart() {
  obj = new TradingSessions();
  Print("test: instantiated");
  ////obj.setSession(NewYork); 
  ////Print("session set to NewYork");
  Print("GMT    : "+obj.showSession(true,gmt));
  //Print("Server : "+obj.showSession(true,server));
  Print("Local  : "+obj.showSession(true,local));
  //Print(obj.showSession(true));  
  //obj.setSession(London); 
  //Print(obj.showSession(true)); 
  Print("Session in local time zone:"); 
  obj.showAllSessions(local);  
  Print("Session in  gmt time zone:"); 
  obj.showAllSessions(gmt);  
  Print("Session in local time zone:"); 
  obj.showAllSessions(local);  
  //Print(obj.showSession(true));  
  //Print("startOfDay="+(string)obj.startOfDay);
  //Print("endOfDay="+(string)obj.endOfDay);
  //Print("nextStartTradeWindow="+(string)obj.nextStartTradeWindow);
  //Print("nextEndTradeWindow="+(string)obj.nextEndTradeWindow);
  //obj.setTradeWindow(NewYork,1);
  
  Print("SessionStartTime: -1 shift = local: ",TimeDayOfWeek(obj.sessionStartTime(local,-1)),"  gmt: ",obj.sessionStartTime(gmt,-1),"  srvr: ",obj.sessionStartTime(server,-1));
  Print("SessionStartTime:  0 shift = local: ",TimeDayOfWeek(obj.sessionStartTime(local,0)),"  gmt: ",obj.sessionStartTime(gmt,0),"  srvr: ",obj.sessionStartTime(server,0));
  Print("SessionStartTime: +1 shift = local: ",TimeDayOfWeek(obj.sessionStartTime(local,1)),"  gmt: ",obj.sessionStartTime(gmt,1),"  srvr: ",obj.sessionStartTime(server,1));
  Print("SessionStartTime: +2 shift = local: ",TimeDayOfWeek(obj.sessionStartTime(local,2)),"  gmt: ",obj.sessionStartTime(gmt,2),"  srvr: ",obj.sessionStartTime(server,2));
  Print("SessionStartTime: +3 shift = local: ",TimeDayOfWeek(obj.sessionStartTime(local,3)),"  gmt: ",obj.sessionStartTime(gmt,3),"  srvr: ",obj.sessionStartTime(server,3));
  Print("SessionStartTime: +4 shift = local: ",TimeDayOfWeek(obj.sessionStartTime(local,4)),"  gmt: ",obj.sessionStartTime(gmt,4),"  srvr: ",obj.sessionStartTime(server,4));
  if (CheckPointer(obj) == POINTER_DYNAMIC) delete obj;
}
