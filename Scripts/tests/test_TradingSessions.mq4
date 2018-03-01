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

#include <dev\TradingSessions2.mqh>

TradingSessions *obj;

void OnStart() {
  obj = new TradingSessions();
  obj.setSession(NewYork); 
  Print("GMT    : "+obj.showSession(true,GMT));
  Print("Server : "+obj.showSession(true,Server));
  Print("Local  : "+obj.showSession(true,Local));
  Print(obj.showSession(true));  
  obj.setSession(London); 
  Print(obj.showSession(true));  
  Print(obj.showAllSessions());  
  Print(obj.showSession(true));  
  Print("startOfDayLocal="+(string)obj.startOfDayLocal);
  Print("endOfDayLocal="+(string)obj.endOfDayLocal);

  if (CheckPointer(obj) == POINTER_DYNAMIC) delete obj;
}
