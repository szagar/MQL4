//+------------------------------------------------------------------+
//|                                               BreakOutTrader.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev\enum_types.mqh>
#include <dev\logger.mqh>

extern bool Testing = false;               //> Testing ?
extern Enum_LogLevels LogLevel = LogDebug;  //> Log Level
extern int Slippage=5;                     //> Slippage in pips
extern int Spread=3;                       //> Spread in pips
extern double PercentRiskPerPosition=0.5;  //> Percent to risk per position
extern double MinReward2RiskRatio = 1.5;   //> Min Reward / Risk 
extern bool GoLong = true;                 //> Go Long ?
extern bool GoShort = false;               //> Go Short ?
extern int MaxBarsPending = 5;             //> #bars until stop entry canceled
extern bool SimulateStopEntry = false;
extern bool SimulateStopExit = false;
#include <dev\BreakOutATS.mqh>

#include <dev\ChartTools.mqh>
#include <dev\TradingSessions.mqh>
#include <dev\logger.mqh>
#include <dev\Broker.mqh>
#include <dev\Trader.mqh>

ChartTools *chart;
TradingSessions *sessionTool;
Broker *broker;
Trader *trader;
ExitManager *exitMgr;
InitialRisk *initRisk;
ProfitTargetModels *profitTgt;
BreakOutATS *ats;

datetime startOfDay, endOfDay, now, submitTime;
bool pendingOrders;

int OnInit() {
  setSomeConstants();

  chart = new ChartTools();
  sessionTool = new TradingSessions();
  broker = new Broker();
  exitMgr = new ExitManager();
  initRisk = new InitialRisk();
  profitTgt = new ProfitTargetModels();
  trader = new Trader(exitMgr,initRisk,profitTgt);
  
  ats = new BreakOutATS(trader);
  ats.OnInit();
 
  startOfDay = sessionTool.startOfDay;
  endOfDay = sessionTool.endOfDay;
  Info("Day start: "+string(startOfDay));
  Info("Day end: "+string(endOfDay));
 
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  if (CheckPointer(trader) == POINTER_DYNAMIC) delete trader;
  if (CheckPointer(profitTgt) == POINTER_DYNAMIC) delete profitTgt;      
  if (CheckPointer(initRisk) == POINTER_DYNAMIC) delete initRisk;      
  if (CheckPointer(exitMgr) == POINTER_DYNAMIC) delete exitMgr;      
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;      
  if (CheckPointer(sessionTool) == POINTER_DYNAMIC) delete sessionTool;      
  if (CheckPointer(chart) == POINTER_DYNAMIC) delete chart;
  EventKillTimer();
}


void OnTick() {
  now = TimeCurrent();
  ats.OnTick();   
  if(isNewBar())
    OnNewBar();
  if(SimulateStopEntry) {
    if(ats.pendingLongEntry && Bid >= ats.pendingLongEntryPrice)
      ats.stopEntrySignaled(Long);
    if(ats.pendingShortEntry && Ask <= ats.pendingShortEntryPrice)
      ats.stopEntrySignaled(Short);
  }
  if(SimulateStopExit) {
    if(ats.pendingLongExit && Ask <= ats.pendingLongExitPrice)
      ats.stopExitSignaled(Long);
    if(ats.pendingShortExit && Bid >= ats.pendingShortExitPrice)
      ats.stopExitSignaled(Short);
  }    
}

void OnNewBar() {
  Info("iBarShift="+string(iBarShift(NULL,0, submitTime)));

  if(isSOD()) ats.startOfDay();
  if(isEOD()) ats.endOfDay();
  ats.OnBar();
}

bool isSOD() {
  if(now >= startOfDay) {
    startOfDay = sessionTool.addDay(startOfDay);
    sessionTool.initSessionTimes();
    return true;
  }
  return(false);
}

bool isEOD() {
  if(now >= endOfDay) {
    endOfDay = sessionTool.addDay(endOfDay);
    return true;
  }
  return(false);
}

bool isNewBar() {
  static datetime time0;
  if(Time[0] == time0) return false;
  time0 = Time[0];
  return true;
}

