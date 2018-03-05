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
//extern Enum_LogLevels LogLevel = LogDebug;  //> Log Level
//extern int Slippage=5;                     //> Slippage in pips
extern int Spread=3;                       //> Spread in pips
extern double PercentRiskPerPosition=0.5;  //> Percent to risk per position
extern double MinReward2RiskRatio = 1.5;   //> Min Reward / Risk 
extern bool GoLong = true;                 //> Go Long ?
extern bool GoShort = false;               //> Go Short ?
extern int MaxBarsPending = 5;             //> #bars until stop entry canceled

extern bool dowExit            = false;
extern bool ExitOnFriday       = false;
extern string ExitTimeOnFriday = "17:00";

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

const int version = 1;
static int optcnt=0;

int OnInit() {
  Info2(__FUNCTION__,__LINE__,"Entered");
  setSomeConstants();

  chart = new ChartTools();
  sessionTool = new TradingSessions(Session);
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
 
  //int handle = openDailySummaryFile();
  //if(handle == 0)
  //  writeDailySummaryHdr();
  //else
  //  FileSeek(handle, 0, SEEK_END);
  optcnt++;
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  Info2(__FUNCTION__,__LINE__,"Entered");
  if(IsTesting()) 
    writeDailySummary((string)optcnt);
  else
    writeDailyTrades();
  if (CheckPointer(ats) == POINTER_DYNAMIC) delete ats;
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
  //Info("iBarShift="+string(iBarShift(NULL,0, submitTime)));

  if(isSOD()) ats.startOfDay();
  if(isEOD()) {
    ats.endOfDay();
    //writeDailySummary();
  }
  if(dowExit)
    checkDayOfWeekExit();
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


int openDailySummaryFile() {
  bool writeHeader;
  string fn = "dailySummary_v"+(string)version+".csv";
  if(!FileIsExist(fn))
    writeHeader = true;
  else
    writeHeader = false;
  int fh=FileOpen(fn, FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_WRITE,';');
  if(writeHeader)
    writeDailySummaryHdr(fh);
  else
    FileSeek(fh, 0, SEEK_END);
  return(fh);  
}

void writeDailySummaryHdr(int fh) {
  FileWrite(fh, "Symbol","TimeFrame","pnlPips",
                "POI_Model","POI_price","POI_ma_period","DIST_atr_period","DIST_atr_factor","Filter_Model",
                "STAT_TRADES",
                "STAT_PROFIT_TRADES",
                "STAT_LOSS_TRADES",
                "STAT_BALANCE_DD",
                "STAT_EQUITY_DD",
                "STAT_INITIAL_DEPOSIT",
                "STAT_PROFIT",
                "STAT_GROSS_PROFIT",
                "STAT_GROSS_LOSS",
                "STAT_MAX_PROFITTRADE",
                "STAT_MAX_LOSSTRADE",
                "STAT_CONPROFITMAX",
                "STAT_CONPROFITMAX_TRADES",
                "STAT_MAX_CONWINS",
                "STAT_MAX_CONPROFIT_TRADES",
                "STAT_CONLOSSMAX",
                "STAT_CONLOSSMAX_TRADES",
                "STAT_MAX_CONLOSSES",
                "STAT_MAX_CONLOSS_TRADES",
                "STAT_BALANCEMIN",
                "STAT_BALANCEDD_PERCENT",
                "STAT_BALANCE_DDREL_PERCENT",
                "STAT_BALANCE_DD_RELATIVE",
                "STAT_EQUITYMIN",
                "STAT_EQUITYDD_PERCENT",
                "STAT_EQUITY_DDREL_PERCENT",
                "STAT_EQUITY_DD_RELATIVE",
                "STAT_EXPECTED_PAYOFF",
                "STAT_PROFIT_FACTOR",
                "STAT_MIN_MARGINLEVEL",
                "STAT_CUSTOM_ONTESTER",
                "STAT_SHORT_TRADES",
                "STAT_LONG_TRADES",
                "STAT_PROFIT_SHORTTRADES",
                "STAT_PROFIT_LONGTRADES",
                "STAT_PROFITTRADES_AVGCON",
                "STAT_LOSSTRADES_AVGCON"
                );

  FileClose(fh);
}
void writeDailyTradesHdr(int fh) {
  FileWrite(fh, "Symbol","TimeFrame","TBD");
}
void writeDailySummary(string prefix="tbd") {
  if(TesterStatistics(STAT_TRADES)==0) return;
  int fh = openDailySummaryFile();
  
  FileWrite(fh,Symbol(),Period(),NormalizeDouble(broker.pnlPipsToday(),2),
               POI_Model,POI_price,POI_ma_period,DIST_atr_period,DIST_atr_factor,Filter_Model,
               TesterStatistics(STAT_TRADES),
               TesterStatistics(STAT_PROFIT_TRADES),
               TesterStatistics(STAT_LOSS_TRADES),
               TesterStatistics(STAT_BALANCE_DD),
               TesterStatistics(STAT_EQUITY_DD),
               TesterStatistics(STAT_INITIAL_DEPOSIT),
               DoubleToStr(TesterStatistics(STAT_PROFIT),2),
               DoubleToStr(TesterStatistics(STAT_GROSS_PROFIT),2),
               DoubleToStr(TesterStatistics(STAT_GROSS_LOSS),2),
               TesterStatistics(STAT_MAX_PROFITTRADE),
               TesterStatistics(STAT_MAX_LOSSTRADE),
               TesterStatistics(STAT_CONPROFITMAX),
               TesterStatistics(STAT_CONPROFITMAX_TRADES),
               TesterStatistics(STAT_MAX_CONWINS),
               TesterStatistics(STAT_MAX_CONPROFIT_TRADES),
               TesterStatistics(STAT_CONLOSSMAX),
               TesterStatistics(STAT_CONLOSSMAX_TRADES),
               TesterStatistics(STAT_MAX_CONLOSSES),
               TesterStatistics(STAT_MAX_CONLOSS_TRADES),
               TesterStatistics(STAT_BALANCEMIN),
               TesterStatistics(STAT_BALANCEDD_PERCENT),
               TesterStatistics(STAT_BALANCE_DDREL_PERCENT),
               TesterStatistics(STAT_BALANCE_DD_RELATIVE),
               TesterStatistics(STAT_EQUITYMIN),
               TesterStatistics(STAT_EQUITYDD_PERCENT),
               TesterStatistics(STAT_EQUITY_DDREL_PERCENT),
               TesterStatistics(STAT_EQUITY_DD_RELATIVE),
               TesterStatistics(STAT_EXPECTED_PAYOFF),
               TesterStatistics(STAT_PROFIT_FACTOR),
               TesterStatistics(STAT_MIN_MARGINLEVEL),
               TesterStatistics(STAT_CUSTOM_ONTESTER),
               TesterStatistics(STAT_SHORT_TRADES),
               TesterStatistics(STAT_LONG_TRADES),
               TesterStatistics(STAT_PROFIT_SHORTTRADES),
               TesterStatistics(STAT_PROFIT_LONGTRADES),
               TesterStatistics(STAT_PROFITTRADES_AVGCON),
               TesterStatistics(STAT_LOSSTRADES_AVGCON)
                );
  FileClose(fh);
}


void writeDailyTrades() {
}
/**
  bool writeHeader;
  string fn = "dailyTrades_v"+(string)version+".csv";
  if(!FileIsExist(fn))
    writeHeader = true;
  else
    writeHeader = false;
  int fh=FileOpen(fn, FILE_CSV|FILE_READ|FILE_SHARE_READ|FILE_WRITE,';');
  if(writeHeader)
    writeDailyTradesHdr(fh);
  else
    FileSeek(fh, 0, SEEK_END);
  for(int i=0;i<OrdersHistoryTotal();i++) {
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true && OrderSymbol() == Symbol()) {
      if(OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) {
        continue;
      }
      if(TimeToStr( OrderOpenTime(), TIME_DATE) == todayTime) {
        Info("Comparing "+TimeToStr(OrderOpenTime(),TIME_DATE)+" = "+todayTime);
        if(OrderType() == OP_BUY) {
          FileWrite(fh,OrderSymbol(),OrderOpenTime(),OrderLots(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(),OrderClosePrice(),OrderCloseTime(),OrderMagicNumber(),OrderProfit(),OrderTicket(),OrderType());
          plToday += OrderClosePrice()-OrderOpenPrice();
        } else {
          plToday += OrderOpenPrice()-OrderClosePrice();
        }
      }
    }
  }

}
**/

void checkDayOfWeekExit() {
  if(ExitOnFriday) {
    int dow = TimeDayOfWeek(Time[0]);
    if(ExitTimeOnFriday == "00:00" || ExitTimeOnFriday == "0:00") {
      if(dow == 6 || dow == 0 || dow == 1) {
        //closeTradeFromPreviousDay();
      }
    } else if(dow == 5 && TimeCurrent() >= TimeStringToDateTime(ExitTimeOnFriday)) {
      broker.closeOpenTrades(Symbol(),ats.strategyName);
      broker.deletePendingOrders(Symbol(),ats.strategyName);
      //closeActiveOrders();
      //closePendingOrders();
    }
  }
}

datetime TimeStringToDateTime(string time) {
  string date = TimeToStr(TimeCurrent(),TIME_DATE);//"yyyy.mm.dd"
  return (TimeStringToDateTime(date + " " + time));
}
