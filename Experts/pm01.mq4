//+------------------------------------------------------------------+
//|                                                           Pm.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS\enum_types.mqh>
#include <ATS\commonConstants.mqh>

#include <ATS\pm_externs.mqh>

#include <ATS\BreakOutATS.mqh>

#include <ATS\logger.mqh>
//#include <ATS\ChartTools.mqh>
#include <ATS\TradingSessions.mqh>
#include <ATS\Broker.mqh>
#include <ATS\Trader.mqh>
#include <ATS\Filters.mqh>
#include <ATS\OptimizerOutput.mqh>

//ChartTools *chart;
TradingSessions *sessionTool;
Broker *broker;
Trader *trader;
ExitManager *exitMgr;
InitialRisk *initRisk;
ProfitTargetModels *profitTgt;
BreakOutATS *ats;
Filters *filters;
OptimizerOutput *optOut;

datetime startOfDay, endOfDay, now, submitTime;
bool pendingOrders;
int barNumber,dayBarNumber,sessionBarNumber;

const int version = 1;
static int optcnt=0;

int OnInit() {
  Info2(__FUNCTION__,__LINE__,"Entered");
  setSomeConstants();

  //chart = new ChartTools();
  sessionTool = new TradingSessions(Session);
  broker = new Broker();
  exitMgr = new ExitManager();
  initRisk = new InitialRisk();
  profitTgt = new ProfitTargetModels();
  trader = new Trader(exitMgr,initRisk,profitTgt);
  filters = new Filters();
  optOut = new OptimizerOutput();
  
  ats = new BreakOutATS(sessionTool,trader);
  ats.OnInit();
 
  startOfDay = sessionTool.startOfDay;
  endOfDay = sessionTool.endOfDay;
  Info("Day start: "+string(sessionTool.startOfDay));
  Info("Day end: "+string(endOfDay));
  Info("Session start: "+string(sessionTool.nextStartTradeWindow));
  Info("Session end: "+string(sessionTool.nextEndTradeWindow));
 
  optcnt++;
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  Info2(__FUNCTION__,__LINE__,"Entered");
  if(IsTesting()) 
    optOut.writeDailySummary((string)optcnt);
  else
    optOut.writeDailyTrades();
  if (CheckPointer(filters) == POINTER_DYNAMIC) delete filters;
  if (CheckPointer(ats) == POINTER_DYNAMIC) delete ats;
  if (CheckPointer(trader) == POINTER_DYNAMIC) delete trader;
  if (CheckPointer(profitTgt) == POINTER_DYNAMIC) delete profitTgt;      
  if (CheckPointer(initRisk) == POINTER_DYNAMIC) delete initRisk;      
  if (CheckPointer(exitMgr) == POINTER_DYNAMIC) delete exitMgr;      
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;      
  if (CheckPointer(sessionTool) == POINTER_DYNAMIC) delete sessionTool;      
  //if (CheckPointer(chart) == POINTER_DYNAMIC) delete chart;
  if (CheckPointer(optOut) == POINTER_DYNAMIC) delete optOut;
  EventKillTimer();
}

void OnTick() {
  now = TimeCurrent();
  if(UseTODexit && TimeCurrent() > ats.Time2CloseTrades) {
    broker.closeOpenTrades(Symbol(),ats.strategyName);
    broker.deletePendingOrders(Symbol(),ats.strategyName);
  }
  if(tickEntry 
     && ats.tradeCnt<=MaxTradesPerDay 
     && sessionTool.tradeWindow2()) {
    if(GoLong)
      if(filters.pass(Long)) {
        if(Testing)
          ats.checkForNewEntry(Long,Close[0],Close[0]+Spread*P2D);
        else
          ats.checkForNewEntry(Long,Bid,Ask);
      }
    if(GoShort)
      if(filters.pass(Short)) {
        if(Testing)
          ats.checkForNewEntry(Short,Close[0],Close[0]+Spread*P2D);
        else
          ats.checkForNewEntry(Short,Bid,Ask);
      }
  }     
  ats.OnTick();   
  if(SimulateStopEntry) {
    if(ats.pendingLongEntry && Bid >= ats.pendingLongEntryPrice)
      ats.stopEntrySignaled(Long);
  }
  if(SimulateStopExit) {
    if(ats.pendingLongExit && Ask <= ats.pendingLongExitPrice)
      ats.stopExitSignaled(Long);
    if(ats.pendingShortExit && Bid >= ats.pendingShortExitPrice)
      ats.stopExitSignaled(Short);
  }  
  if(isNewBar())
    OnNewBar();
}

void runSOD() {
  filters.setDaily();
  ats.startOfDay();
}

void runEOD() {
  if(UseEODexit) { 
    broker.closeOpenTrades(Symbol(),ats.strategyName);
    broker.deletePendingOrders(Symbol(),ats.strategyName);
  }
  broker.PrintOpenTrades();
  broker.PrintPendingOrders();

  ats.endOfDay();
  //writeDailySummary();
}

void OnNewBar() {
  //Info("iBarShift="+string(iBarShift(NULL,0, submitTime)));
  barNumber++;
  sessionTool.onNewBar(Time[0]);
  if(sessionTool.newDayBar) runSOD();
  
  Print("barNumber=",barNumber,"  dayBarNumber=",sessionTool.dayBarNumber,"  sessionBarNumber=",sessionTool.sessionBarNumber);

  pendingOrders = broker.cntPendingOrders(Symbol(),ats.strategyName);
  Print("Pending orders =",pendingOrders);

  if(UseBarsInExit) {
    //// for each open trade ...
    //  if(barNumber-entryBar)>BarsInTrade) {
    //    broker.closeOpenTrades(Symbol(),ats.strategyName);
    //    broker.deletePendingOrders(Symbol(),ats.strategyName);
    //  }
    //}
  }

  //if(dowExit)
  //  checkDayOfWeekExit();
  Info2(__FUNCTION__,__LINE__,(string)UseBarsInPending+" && "
        +(string)pendingOrders+" && iBarShift(NULL,0, "
        +(string)submitTime+") > "
        +(string)MaxBarsPending+"  => "+(string)iBarShift(NULL,0, submitTime));
  if(UseBarsInPending && pendingOrders && iBarShift(NULL,0, submitTime) > MaxBarsPending) {
    Info("Max Pending Bars hit, pending orders canceled!!");
    pendingOrders = false;
    broker.deletePendingOrders(Symbol(),ats.strategyName); 
  }
  if(UseTrailingStop) {
  }
  if(barEntry
     && ats.tradeCnt<MaxTradesPerDay
     && sessionTool.tradeWindow2()) {
    ats.OnBar(true);
    if(GoLong)
      if(filters.pass(Long)) {
        if(Testing)
          ats.checkForNewEntry(Long,Close[0],Close[0]+Spread*P2D);
        else
          ats.checkForNewEntry(Long,Bid,Ask);
      }
    if(GoShort)
      if(filters.pass(Short)) {
        if(Testing)
          ats.checkForNewEntry(Short,Close[0],Close[0]+Spread*P2D);
        else
          ats.checkForNewEntry(Short,Bid,Ask);
      }
  } else {
    ats.OnBar(false);
  }
  sessionTool.closeOfBar();
  if(sessionTool.isEOD()) runEOD();
}

//bool isStartOfNewSession() {
//  if(Time[0] >= sessionTool.startTradingSession_Server) {
//    sessionTool.startTradingSession_Server = sessionTool.addDay(sessionTool.startTradingSession_Server);
//    return true;
//  }
//  return false;
//}

bool isNewBar() {
  static datetime time0;
  if(Time[0] == time0) return false;
  time0 = Time[0];
  return true;
}

void checkDayOfWeekExit() {
  if(ExitOnFriday) {
    int dow = TimeDayOfWeek(Time[0]);
    //if(ExitTimeOnFriday == "00:00" || ExitTimeOnFriday == "0:00") {
    //  if(dow == 6 || dow == 0 || dow == 1) {
    //    //closeTradeFromPreviousDay();
    //  }
    //} else if(dow == 5 && TimeCurrent() >= TimeStringToDateTime(ExitTimeOnFriday)) {
    //  broker.closeOpenTrades(Symbol(),ats.strategyName);
    //  broker.deletePendingOrders(Symbol(),ats.strategyName);
    //  //closeActiveOrders();
    //  //closePendingOrders();
    //}
  }
}
//  string date = TimeToStr(TimeCurrent(),TIME_DATE);//"yyyy.mm.dd"
//  return (TimeStringToDateTime(date + " " + time));
//}
