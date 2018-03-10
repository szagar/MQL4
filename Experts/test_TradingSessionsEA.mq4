//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS\TradingSessions.mqh>

extern bool Testing = false;
extern Enum_LogLevels LogLevel = LogDebug;    //>> Log Level

extern bool barEntry = true;
extern bool tickEntry = true;

TradingSessions *sessionTool;

//datetime startOfDay, endOfDay,
datetime now, submitTime;
int barNumber;
//,dayBarNumber;

int OnInit() {
  Info2(__FUNCTION__,__LINE__,"Entered");

  sessionTool = new TradingSessions(Session);
  
  Info("Day start: "+string(sessionTool.startOfDay));
  Info("Day end: "+string(sessionTool.endOfDay));
 
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  Info2(__FUNCTION__,__LINE__,"Entered");
  if (CheckPointer(sessionTool) == POINTER_DYNAMIC) delete sessionTool;      
}

void OnTick() {
  now = TimeCurrent();
  //if(UseTODexit && now > Time2CloseTrades) {
  //  Print("Close trades @",now);
  //}
  if(tickEntry 
     && sessionTool.tradeWindow2()) {    //Session,SessionSegment)) {
      Print("OnTick: in trade window");
  }     

  //if(SimulateStopEntry) {
  //  if(ats.pendingLongEntry && Bid >= ats.pendingLongEntryPrice)
  //    ats.stopEntrySignaled(Long);
  //}
  //if(SimulateStopExit) {
  //  if(ats.pendingLongExit && Ask <= ats.pendingLongExitPrice)
  //    ats.stopExitSignaled(Long);
  //  if(ats.pendingShortExit && Bid >= ats.pendingShortExitPrice)
  //    ats.stopExitSignaled(Short);
  //}  
  if(isNewBar())
    OnNewBar();
}

void OnNewBar() {
  //Info("iBarShift="+string(iBarShift(NULL,0, submitTime)));
  if(sessionTool.isEOD(Time[0])) runEOD();
  if(sessionTool.isSOD(Time[0])) runSOD();
  barNumber++;
  //dayBarNumber++;
  sessionTool.onNewBar(Time[0]);
  
  Print("barNumber=",barNumber,"  dayBarNumber=",sessionTool.dayBarNumber,"  sessionBarNumber=",sessionTool.sessionBarNumber);

  if(barEntry && sessionTool.tradeWindow2()) Print("** In Session **");
  //if(barEntry && sessionTool.tradeWindow(Session,SessionSegment)) {
  //  //Print("OnNewBar: in trade window");
  //}
  sessionTool.closeOfBar();
  //if(sessionTool.isEOD(Time[0])) runEOD();
}

void runSOD() {
}

void runEOD() {
}

bool isNewBar() {
  static datetime time0;
  if(Time[0] == time0) return false;
  time0 = Time[0];
  return true;
}

//void checkDayOfWeekExit() {
//  if(ExitOnFriday) {
//    int dow = TimeDayOfWeek(Time[0]);
//    //if(ExitTimeOnFriday == "00:00" || ExitTimeOnFriday == "0:00") {
//    //  if(dow == 6 || dow == 0 || dow == 1) {
//    //    //closeTradeFromPreviousDay();
//    //  }
//    //} else if(dow == 5 && TimeCurrent() >= TimeStringToDateTime(ExitTimeOnFriday)) {
//    //  broker.closeOpenTrades(Symbol(),ats.strategyName);
//    //  broker.deletePendingOrders(Symbol(),ats.strategyName);
//    //  //closeActiveOrders();
//    //  //closePendingOrders();
//    //}
//  }
//}
//  string date = TimeToStr(TimeCurrent(),TIME_DATE);//"yyyy.mm.dd"
//  return (TimeStringToDateTime(date + " " + time));
//}
