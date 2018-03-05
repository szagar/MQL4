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
  obj.setSession(NewYork); 
  Print("GMT    : "+obj.showSession(true,"GMT"));
  Print("Server : "+obj.showSession(true,"Server"));
  Print("Local  : "+obj.showSession(true,"Local"));
  Print(obj.showSession(true));  
  obj.setSession(London); 
  Print(obj.showSession(true));  
  obj.showAllSessions();  
  Print(obj.showSession(true));  
  Print("startOfDay="+(string)obj.startOfDay);
  Print("endOfDay="+(string)obj.endOfDay);
  Print("nextStartTradeWindow="+(string)obj.nextStartTradeWindow);
  Print("nextEndTradeWindow="+(string)obj.nextEndTradeWindow);
  obj.setTradeWindow(NewYork,1);
  
  if (CheckPointer(obj) == POINTER_DYNAMIC) delete obj;
}
