//+------------------------------------------------------------------+
//|                                                          ATS.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev/Trader.mqh>
#include <dev/Filters.mqh>
#include <dev/MagicNumber.mqh>
#include <dev/TradingSessions.mqh>

extern bool tickEntry = false;  // check new entry on tick
extern bool barEntry = true;    // check new entry on bar

class ATS {
protected:
  void markOnChart(datetime,double);
  int barNumber;
  int dayBarNumber;
  int sessionBarNumber;
  

  void initialize();
  bool isStartOfNewSession();

public:
  string strategyName;
  bool callOnTick;
  bool callOnBar;
  //bool triggered;

  string symbol;
  int roboID;
  int tradeNumber;

  bool pendingLongEntry, pendingShortEntry;
  bool pendingLongExit, pendingShortExit;
  double pendingLongEntryPrice, pendingShortEntryPrice;
  double pendingLongExitPrice, pendingShortExitPrice;
  
  //double rboPrice;
  Trader *trader;
  MagicNumber *magic;
  Filters *filters;
  TradingSessions *sessionTool;
  
  ATS(Trader*);
  ATS(string,Trader*);
  ~ATS();
  
  virtual void OnInit()        { Debug(__FUNCTION__,__LINE__,"Entered"); };
  virtual void startOfDay()    { Debug(__FUNCTION__,__LINE__,"Entered"); }
  virtual void OnTick()        { Debug(__FUNCTION__,__LINE__,"Entered"); };
  virtual void OnBar();
  virtual void defaultParameters() { Debug(__FUNCTION__,__LINE__,"Entered"); };
  virtual void reset();
  virtual void cleanUpEOD()    { Debug(__FUNCTION__,__LINE__,"Entered"); };
  
  virtual bool inTradeWindow();
  virtual bool filtersPassed(Enum_SIDE side) { return(filters.passFail(side)); };
  void stopExitSignaled(Enum_SIDE);
  void stopEntrySignaled(Enum_SIDE);
};


ATS::ATS(Trader *t) {
  trader = t;
  initialize();
}

ATS::ATS(string _symbol, Trader *t) {
  symbol = _symbol;
  trader = t;
  initialize();
}

ATS::~ATS() {
  if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
}

void ATS::initialize() {
  filters = new Filters();
  magic = new MagicNumber();
  sessionTool = new TradingSessions();
  callOnTick = false;
  callOnBar = false;
  //triggered = false;
}

void ATS::reset() {
  //triggered=false;
  //side = sideSave;
  if(UseDefaultParameters) defaultParameters();
};  

void ATS::OnBar(void) {
  barNumber++;
  dayBarNumber++;
  sessionBarNumber++;
  if(isStartOfNewSession())
    sessionBarNumber = 1;
}

bool ATS::isStartOfNewSession() {
  if(Time[0] >= sessionTool.startTradingSession_Server) {
    sessionTool.startTradingSession_Server = sessionTool.addDay(sessionTool.startTradingSession_Server);
    return true;
  }
  return false;
}

void ATS::markOnChart(datetime time, double price) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  static int objCnt=0;
  string objname;
  Info("Draw arrow "+TimeToStr(time)+ "@ "+DoubleToStr(price,Digits));
  objname = strategyName+"_"+IntegerToString(objCnt++);
  //Comment("Draw Object: "+objname);
  ObjectCreate(objname,OBJ_ARROW,0,time,price);
  ObjectSetInteger(0,objname,OBJPROP_COLOR,clrBlack);
}
  
void ATS::stopExitSignaled(Enum_SIDE side) {
  trader.closeOpenPositions(side,magic.get(strategyName));
}

void ATS::stopEntrySignaled(Enum_SIDE side) {
  trader.enterCurrentMarket(side);
}

 bool ATS::inTradeWindow() {
  return true;
}
