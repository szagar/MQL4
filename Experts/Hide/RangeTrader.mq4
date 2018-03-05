//+------------------------------------------------------------------+
//|                                                  RangeTrader.mq4 |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev\enum_types.mqh>
#include <dev\ChartTools.mqh>
#include <dev\TradingSessions.mqh>
#include <dev\logger.mqh>
#include <dev\Broker.mqh>
#include <dev\Trader.mqh>
#include <dev\RboSetup.mqh>

extern bool Testing = false;               //- Testing ?
extern Enum_LogLevels LogLevel = LogInfo;  //- Log Level
extern int Slippage=5;                     //- Slippage in pips
extern double PercentRiskPerPosition=0.5; //>- Percent to risk per position
extern double MinReward2RiskRatio = 1.5;   //- Min Reward / Risk 
extern bool GoLong = true;                 //- Go Long ?
extern bool GoShort = false;               //- Go Short ?

extern bool tradeAsiaRange=false;
extern bool tradeLondonRange=false;
//extern bool tradeNewYorkRange=false;
extern bool twoMinRule = false;            // 2 minute rule

//extern int entryPriceBufferPips=1;
//extern int oneRpips=10;
//extern double reward2risk=2.0;

ChartTools *chart;
TradingSessions *sessionTool;
Broker *broker;
Trader *trader;
ExitManager *exitMgr;
InitialRisk *initRisk;
ProfitTargetModels *profitTgt;

bool drawAsia, drawLondon;
bool tradeAsiaSave;
bool tradeLondonSave;
bool pendingOrders;
datetime startOfDay, now, submitTime;

int OnInit()
{
  setSomeConstants();
  tradeAsiaSave = tradeAsiaRange;
  tradeLondonSave = tradeLondonRange;
  if(tradeAsiaSave) drawAsia = true;
  if(tradeLondonSave) drawLondon = true;

  chart = new ChartTools();
  sessionTool = new TradingSessions();
  broker = new Broker();
  exitMgr = new ExitManager();
  initRisk = new InitialRisk();
  profitTgt = new ProfitTargetModels();
  trader = new Trader(exitMgr,initRisk,profitTgt);
 
  startOfDay = sessionTool.startOfDay;
  Info("Day start to end: "+string(startOfDay));
 
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  if (CheckPointer(trader) == POINTER_DYNAMIC) delete trader;      
  if (CheckPointer(profitTgt) == POINTER_DYNAMIC) delete profitTgt;      
  if (CheckPointer(initRisk) == POINTER_DYNAMIC) delete initRisk;      
  if (CheckPointer(exitMgr) == POINTER_DYNAMIC) delete exitMgr;      
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;      
  if (CheckPointer(sessionTool) == POINTER_DYNAMIC) delete sessionTool;      
  if (CheckPointer(chart) == POINTER_DYNAMIC) delete chart;
  EventKillTimer();
}


void OnNewBar() {
  now = TimeCurrent();
  Info("iBarShift="+iBarShift(NULL,0, submitTime));
  if(pendingOrders && iBarShift(NULL,0, submitTime) > 3) 
    deletePendingOrders(); 

  if(isSOD()) {
    sessionTool.initSessionTimes();
    Comment(TimeToStr(startOfDay)+"\n"+
    "    Asia: "+TimeToStr(sessionTool.startTimeForSession(Asia))+"\n"+
    "  London: "+TimeToStr(sessionTool.startTimeForSession(London))+"\n"+
    " NewYork: "+TimeToStr(sessionTool.startTimeForSession(NewYork)));
    Info("SOD bar");
    if(tradeAsiaSave) {
      drawAsia = true;
      tradeAsiaRange = true;
    }
    if(tradeLondonSave) {
      drawLondon = true;
      tradeLondonRange = true;
    }
  }

}

void OnTick()
{
  if(isNewBar()) {
    OnNewBar();
  }
  if(drawAsia && Time[0] > sessionTool.endTimeForSession(Asia)) {
    Info("draw asia");
    drawAsia = false;
    chart.drawRange_session(Asia,false);    
  }
  //if(tradeAsiaRange && Time[0] > sessionTool.startTimeForSession(London)) {
  if(tradeAsiaRange && Time[0] > sessionTool.endTimeForSession(Asia)) {
    if(GoLong && iHigh(NULL,0,0) > chart.getSessionHigh("Asia")) {
      Info("trade asia");
      tradeAsiaRange = false;
      bracketSessionRange(Asia,chart.getSessionHigh("Asia"),chart.getSessionLow("Asia"));
    }
  }
  if(drawLondon && Time[0] > sessionTool.startTimeForSession(London)) {
    Info("draw london");
    drawLondon = false;
    chart.drawRange_session(London,false);    
  }
  if(tradeLondonRange && Time[0] > sessionTool.startTimeForSession(NewYork)) {
      Info("trade london");
    tradeLondonRange = false;
    bracketSessionRange(London,chart.getSessionHigh("London"),chart.getSessionLow("London"));
  }

}

void bracketSessionRange(Enum_Sessions session,double upper,double lower) {
  Info2(__FUNCTION__,__LINE__,EnumToString(session)+"  upper="+DoubleToStr(upper,Digits)+"  lower="+DoubleToStr(lower,Digits));
  Position *trade;
  RboSetup *setup;

  if(GoLong) {
    setup = new RboSetup(Long);
    setup.rboPrice = upper + 5*P2D;
    trade = trader.newTrade(setup);
    delete(setup);
    Info2(__FUNCTION__,__LINE__,"trade: "+trade.toHuman());
    broker.CreateOrder(trade);
    delete(trade);
  }
  if(GoShort) {
    setup = new RboSetup(Short);
    setup.rboPrice = lower;
    trade = trader.newTrade(setup);
    delete(setup);
    Info2(__FUNCTION__,__LINE__,"trade: "+trade.toHuman());
    broker.CreateOrder(trade);
    delete(trade);
  }
  pendingOrders = true;
  submitTime = TimeCurrent();
}


bool isSOD() {
  if(now >= startOfDay) {
    startOfDay = sessionTool.addDay(startOfDay);
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

void OnTimer() {
  deletePendingOrders();
}

void deletePendingOrders() {
  Info2(__FUNCTION__,__LINE__,"Entered");
  bool deleted;
  pendingOrders = false;
  if (OrdersTotal()==0) return;
  for (int i=OrdersTotal()-1; i>=0; i--) {
    Info2(__FUNCTION__,__LINE__,OrderSymbol()+" "+OrderType());
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) {
      Info2(__FUNCTION__,__LINE__,"in: "+OrderSymbol()+" "+OrderType());
      if (OrderType()==4) {
        deleted=OrderDelete(OrderTicket());
        if (deleted==false) Info("Error: " + GetLastError());
        if (deleted==true) Info("Order " + OrderTicket() + " Deleted.");
      }
      if (OrderType()==5) {
        deleted=OrderDelete(OrderTicket());
        if (deleted==false) Print ("Error: ",  GetLastError());
        if (deleted==true) Print ("Order ", OrderTicket() ," Deleted.");
      }
    }
  }
}
