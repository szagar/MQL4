//+------------------------------------------------------------------+
//|                                                          ATS.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <ATS/entry_externs.mqh>
#include <ATS/Filters.mqh>
#include <ATS/TradingSessions.mqh>
#include <ATS/Trader.mqh>


class ATS {
protected:
  void markOnChart(datetime,double);
  
  void initialize();
  bool isStartOfNewSession();

public:
  string strategyName;
  bool callOnTick;
  bool callOnBar;
  datetime entryTime, Time2CloseTrades;

  string symbol;
  int roboID;

  int entryBar; 
  int tradeNumber;
  int tradeCnt;

  bool pendingLongEntry, pendingShortEntry;
  bool pendingLongExit, pendingShortExit;
  double pendingLongEntryPrice, pendingShortEntryPrice;
  double pendingLongExitPrice, pendingShortExitPrice;
  
  virtual void checkForNewEntry(double bid, double ask);
  
  Trader *trader;
  //MagicNumber *magic;
  Filters *filters;
  TradingSessions *sessionTool;
  
  ATS(TradingSessions*,Trader*);
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
  virtual bool filtersPassed(Enum_SIDE side) { return(filters.pass(side)); };
  void stopExitSignaled(Enum_SIDE);
  void stopEntrySignaled(Enum_SIDE);
  
  virtual string inputsHdr();  //(string& hdrArray[]);
};


ATS::ATS(TradingSessions *st,Trader *t) {
  sessionTool = st;
  trader = t;
  initialize();
}

ATS::ATS(string _symbol, Trader *t) {
  symbol = _symbol;
  trader = t;
  initialize();
}

ATS::~ATS() {
  //if (CheckPointer(sessionTool) == POINTER_DYNAMIC) delete sessionTool;
  if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
  if (CheckPointer(filters) == POINTER_DYNAMIC) delete filters;
}

void ATS::initialize() {
  filters = new Filters();
  //magic = new MagicNumber();
  //sessionTool = new TradingSessions();
  callOnTick = false;
  callOnBar = false;
}

void ATS::reset() {
  tradeCnt = 0;
};  

void ATS::OnBar(void) {
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
  SetupStruct *setup;
  setup = new SetupStruct();
  setup.strategyName = strategyName;
  setup.side         = Long;
  setup.symbol       = Symbol();
  int tid=trader.marketEntryOrder(setup);
  if (CheckPointer(setup) == POINTER_DYNAMIC) delete setup;
  entryBar = barNumber;
  entryTime = Time[0];
  if(UseTODexit)
    Time2CloseTrades = Time[0] + HoursInTrade*3600 + MinutesInTrade*60;;
}

 bool ATS::inTradeWindow() {
  return sessionTool.tradeWindow(Session,SessionSegment);
}

string ATS::inputsHdr() {  //string& hdrArray[]) {
  string rtn="";
  string srcArray[] = {"MaxBarsPending"};
  for(int i=0;i<ArraySize(srcArray);i++) {
    StringConcatenate(rtn,srcArray[i],";");
  }
  return(rtn);
}

