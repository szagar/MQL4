
class Describe {
private:
  string description;
public:
  void Describe() {
    description = "";
  }
  void ~Describe() {}
  void buildDesc(string text) {
    description += text + "\n";
  }
  string getDescription() {
    return(description);
  }
};


//+------------------------------------------------------------------+
//|                                                        zts04.mqh |
//|   Trade with Models:
//|       Market Model:  
//|               when: before looking for setups
//|               0 : no check
//|               1 : Long if close > 200 SMA, Short if close < 200 SMA
//|       Equity Model: 
//|               when: before looing for setups
//|               1 : current free margin
//|       Position Size Model: 
//|               when: before trade setup
//|               1 : 0.01 lots
//|               2 : (Equity * PercentRiskPerPos) / 1Rpips
//|       Setup Model: 
//|               when: for each new bar, after market checked for L/S conditions
//|       Entry Model:                                                                      EntryModel=0
//|               when: after setup model confirms trade condition
//|               0 : enter now, Long at ask, Short at bid
//|               1 : enter on pullback to previous bar's H/L (bar offset)                  EntryPBbarOffset=1
//|               2 : enter on RBO of current session (pip offset)                          EntryRBOpipOffset=1
//|       Risk Model: 
//|         Stop Trading Model(1R): 
//|               when : before checking for new trades
//|               0/1 : no new trades if current real + unreal pnl is >                     MaxDailyRiskPips
//|               0/1 : no new trades if number of open positions >= N trades (ntrades=6)   MaxConcurrentPositions
//|         Initial Risk Model(1R):                                                         RiskOneR=1
//|               when: before trade setu                                                   RiskATRmultiplier=2.7
//|               1 : PATI static pips                                                      RiskATRperiod=0
//|               2 : ATR(multiplier, ATRperiod, number periods)                            RiskATRnumPeriods=14
//|               3 : moving average(type,period,buffer pips)                               RiskMAtype=EMA|SMA
//|                                                                                         RiskMAperiod=10
//|                                                                                         RiskMAplusPips=2
//|         Rsik Thresholds Model(1R): 
//|               when: before trade setup
//|               * percent risk per position                                              PercentRiskPerPos=0.5
//|               * daily risk level in pips                                               MaxDailyRiskPips=50
//|               
//|       Exit Model: 
//|         Partial Profit Model:                                                          ExitPartialProfit=0
//|               0 : use default
//|               1 : full exit
//|               2 : 1st profitable target is 1/2 position
//|         Time Exit Model:                                                               TimeExitModel=0
//|               when: for each new bar
//|               0 : use default                                                         
//|               1 : no time exit                                                         
//|               2 : at number of bars after entry (N bars)                               TimeExitEntryBars=0
//|               3 : at N bars after current session (N bars)                             TimeExitSessionBars=0
//|               4 : at hh:mm (exit time)                                                 TimeExitTime
//|         Trailing Stop Model:                                                           TrailingStopModel=0
//|               when: for each new bar
//|               0 : use default
//|               1 : no trailing stop
//|               2 : trail at previous bar H/L                                           TrailingStopATRmultiplier=2.7
//|               3 : trail at N * ATR (muliplier, ATR period, number periods)            TrailingStopATRperiod=D
//|               4 : trail at 1R                                                         TrailingStopATRnumPeriods=14
//|         Profit Target Model:                                                          ProfitExitModel=1
//|               when: for each new bar
//|               0 : use default
//|               1 : no profit target exit
//|               2 : at next PATI level
//|       
//+------------------------------------------------------------------+
#property strict

#include <zts\common.mqh>
#include <zts\MagicNumber.mqh>
#include <zts\TradingSessions.mqh>
#include <zts\Trader.mqh>

extern string RoboParams = "=== Robo Params ===";
extern int MarketModel = 1;
extern Enum_Sessions tradingSession = NewYork;
extern int EngulfingType = 1;
extern string ExitParams = "=== Exit Params ===";
extern int InitStopModel = 0;
//extern int TrailingStopModel = 0;
//extern int TimeExitModel = 0;
//extern int ProfitExitModel = 0;
extern string EntryParams = "=== Entry Params ===";
extern int SetupId = 0;
extern int EntryModel = 0;
extern int YellowLineBarShift = 1;
extern int RSIperiod = 3;

#include <zts\RiskManager.mqh>
#include <zts\Account.mqh>
#include <zts\Broker.mqh>
#include <zts\oneR.mqh>
#include <zts\position_sizing.mqh>
#include <zts\TradingSessions.mqh>
#include <zts\MarketCondition.mqh>
#include <zts\Trader.mqh>

extern string _dummy2 = "=== EquityManager Params ===";
extern int EquityModel = 1;

class Robo {
private:
  bool pendingSetup;
  bool rangeIsSet;
  int exitStrats[5];
  int exitStratCnt;
  int setupList[5];
  int totalPositions;
  double position;
  string symbol;

  int sessionBarNumber;
  
  ///int MagicNumber;
  bool useTrailingStop;

  double rangeLower, rangeUpper;
  RiskManager *riskMgr;
  Account *account;
  Broker *broker;
  Describe *about;
  MagicNumber *magic;
  TradingSessions *session;
  MarketCondition *market;
  Trader *trader;
  
  void updateStop(string,int);

  bool longSetup();
  bool shortSetup();
  int barsSince(datetime);
  bool isStartOfNewSession();
  
public:
  //datetime startTradingSession_Server;
  datetime endTradingSession_Server;
  datetime startTradingDay_Server;
  datetime endTradingDay_Server;
  int dayBarNumber;

  Robo();
  ~Robo();
  
  int OnInit();
  void OnDeinit();
  void OnTick(bool=false);
  void OnNewBar();
  
  //void addSetup(int);
  void cleanUpEOD();
  void startOfDay();
  void handleOpenPositions();
  void updatePendingOrders();

  void checkForSetups();
};

Robo::Robo() {
  pendingSetup = false;
  rangeIsSet = false;
  exitStratCnt = 0;
  riskMgr = new RiskManager(EquityModel,RiskModel);
  account = new Account();
  broker = new Broker();
  about = new Describe();
  magic = new MagicNumber();
  market = new MarketCondition(MarketModel);
  session = new TradingSessions(tradingSession);
  trader = new Trader();
  symbol = broker.NormalizeSymbol(Symbol());
}
  
Robo::~Robo() {
  if (CheckPointer(trader) == POINTER_DYNAMIC) delete trader;
  if (CheckPointer(session) == POINTER_DYNAMIC) delete session;
  if (CheckPointer(market) == POINTER_DYNAMIC) delete market;
  if (CheckPointer(trader) == POINTER_DYNAMIC) delete trader;
  if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
  if (CheckPointer(about) == POINTER_DYNAMIC) delete about;
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;
  if (CheckPointer(account) == POINTER_DYNAMIC) delete account;
  if (CheckPointer(riskMgr) == POINTER_DYNAMIC) delete riskMgr;
}

int Robo::OnInit() {
  session.setSession(Asia);
  session.showAllSessions();
  session.showAllSessions("gmt");
  session.showAllSessions("local");
  Debug(session.showSession());
  Debug(session.showSession(true));
  session.setSession(London);
  Debug(session.showSession());
  Debug(session.showSession(true));
  session.setSession(LondonClose);
  Debug(session.showSession());
  Debug(session.showSession(true));
  session.setSession(tradingSession);
  session.setSession(NYSE);
  Debug(session.showSession());
  Debug(session.showSession(true));
  //setSessionTimes();
  ///dayBarNumber = barsSince(startTradingDay_Server);
  dayBarNumber = barsSince(session.startOfDayLocal);
  sessionBarNumber = barsSince(session.startTradingSession_Server);
  Debug("Bars since: SOD: "+string(dayBarNumber) + "   Bars since: SOS: "+string(sessionBarNumber));
  return(0);
}

void Robo::OnDeinit() { }
void Robo::OnTick(bool tradeWindow) { }

void Robo::OnNewBar() {   //bool tradeWindow) {
  //Info(" Robo::OnNewBar()");    
  //Info("Bar: Local: "+string(TimeLocal())+"  Current: "+string(TimeCurrent())+"  GMT:"+string(TimeGMT())+"  Time[0]:"+string(Time[0])+"   SOD: "+string(dayBarNumber) + "   Bars since: SOS: "+string(sessionBarNumber));

  Position *newTrade;
  dayBarNumber++;
  sessionBarNumber++;
  if(isStartOfNewSession())
    sessionBarNumber = 1;

  //Info(TimeToString(Time[0])+"Bars since: SOD: "+string(dayBarNumber) + "   Bars since: SOS: "+string(sessionBarNumber));
  
  handleOpenPositions();
  updatePendingOrders();
  if(session.tradeWindow(London)) Info("London session");
  if(session.tradeWindow(NYSE)) Info("NYSE session");
  if(session.tradeWindow()) {
    if(market.canGoLong())
      if(longSetup()) {
        newTrade = trader.newTrade();
        broker.CreateOrder(newTrade);
        if (CheckPointer(newTrade) == POINTER_DYNAMIC) delete newTrade;
      }
    if(market.canGoShort())
      if(shortSetup()) {
        newTrade = trader.newTrade();
        broker.CreateOrder(newTrade);
        if (CheckPointer(newTrade) == POINTER_DYNAMIC) delete newTrade;
      }
  }
}
  
//void Robo::setExitStrategy(int _strategyIndex) { 
//  exitStrats[exitStratCnt++] = _strategyIndex;
//}
//void Robo::addSetup(int _setupIndex) {
//  setupList[setupCnt++] = _setupIndex;
//}
void Robo::cleanUpEOD() { }
void Robo::startOfDay() { }

/*
void Robo::checkForSetups() {
  for(int i=0;i<setupCnt;i++) {
    switch(i) {
      case 1:     // RBO
        if(!rangeIsSet) continue;
        break;
      case 2:     // CDM
        if(!rangeIsSet) continue;
        if((Close[0] - rangeUpper) >= 20)
          newYellowLine("Long");
        if((rangeLower - Close[0]) >= 20)
          newYellowLine("Short");
        break;
      default:
        Warn(__FUNCTION__+": setup ID not handled!");
    }
  }
}
*/

//void Robo::newYellowLine(string side) {
//}


/*
void Robo::setRange(datetime start, datetime end, 
                    datetime& TimeCopy[], double& HighPrices[], double& LowPrices[]) {
  double dayHi = 0.0;
  double dayLo = 9999.99;
  datetime dayHiTime, dayLoTime;
  
  datetime _nowServer = TimeCopy[0];
  if (_nowServer < end) end = _nowServer;
  int candlePeriod = int(TimeCopy[0] - TimeCopy[1]);
  int interval = int((_nowServer - start)/ candlePeriod); 
  while(TimeCopy[interval] <= end && interval > 0) {
    if (HighPrices[interval] >dayHi) {
      dayHi = HighPrices[interval];
      dayHiTime = TimeCopy[interval];
    }
    if (LowPrices[interval] < dayLo) {
      dayLo = LowPrices[interval];
      dayLoTime = TimeCopy[interval];
    }
    interval--;
  }
}
*/


/**
void Robo::configExitStrategies() {
  about.buildDesc("* Exit Strategies:");
  //setExitStrategy(1);
  switch(InitStopModel) {
    case 0:
      about.buildDesc("Init Stop Loss: PATI pips");
      //initStopLossIsStatic = true;
      //oneR = riskMgr.oneR_calc_PATI();
      break;
    case 1:
      about.buildDesc("Init Stop Loss: ATR");
      //initStopLossIsStatic = true;
      //oneR = riskMgr.oneR_calc_ATR();
      break;
    default:
      about.buildDesc("Init Stop Loss: NOT DEFINED, using defualt");
      Warn(__FUNCTION__+": InitStopModel not defined!");
  }
  switch(TrailingStopModel) {
    case 0:
      break;
    default:
      Warn(__FUNCTION__+": InitStopModel not defined!");
  }
  switch(TimeExitModel) {
    case 0:
      break;
    default:
      Warn(__FUNCTION__+": InitStopModel not defined!");
  }
  switch(ProfitExitModel) {
    case 0:
      break;
    default:
      Warn(__FUNCTION__+": InitStopModel not defined!");
  }
}
**/

void Robo::handleOpenPositions() {
  int lastError = 0;
  totalPositions=0;
  position=0;
  Debug("handleOpenPositions entered");
  Debug("OrdersTotal()="+string(OrdersTotal()));
  for(int i=OrdersTotal()-1; i>=0; i--)  {
    if(!OrderSelect(i,SELECT_BY_POS)) {
      lastError = GetLastError();
      Warn("OrderSelect("+string(i)+", SELECT_BY_POS) - Error #"+string(lastError));
      continue;
    }
    if(OrderSymbol() != Symbol()) continue;
    Debug(symbol+": Strategy="+magic.getStrategy(OrderMagicNumber())+"  magic="+string(OrderMagicNumber()));
    //if(StringCompare(magic.getStrategy(OrderMagicNumber()), "CDM-YL", false)!=0) continue;
    Debug("OK next");
    if(OrderType() == OP_BUY ) {
      totalPositions++;
      position += double(OrderLots());
      //updateTradeStats();    // unrealized pips, numbars
      if(true) useTrailingStop = true;
      int oneR = magic.getOneR(OrderMagicNumber());
      Debug("handleOpenPositions: oneR="+string(oneR));
      if(useTrailingStop) 
        updateStop("Long",magic.getOneR(OrderMagicNumber()));
    }
    
    if(OrderType() == OP_SELL) {
      totalPositions++;
      position -= double(OrderLots());
      //useTrailingStop || useTrailingStop = riskMgr.checkTrailingStopTrigger();
      if(true) useTrailingStop = true;
      if(useTrailingStop)
        updateStop("Short",magic.getOneR(OrderMagicNumber()));
    }
  }
}

void Robo::updatePendingOrders() {
}

void Robo::updateStop(string side,int oneR) {
  double newStopLoss;
  Debug("updateStop entered:  side="+side+"   oneR="+string(oneR));
  double newTS = riskMgr.getTrailingStop(side,oneR);
  //double newLockIn = riskMgr.getLockIn(side);   // breakeven
  Debug("newTS="+string(newTS));

  newStopLoss = newTS;
  if(newStopLoss > 0)
    broker.modifyStopLoss(OrderTicket(),newStopLoss);
}


void Robo::checkForSetups(void) {
  Debug("checkForSetups entered");
  if(MathAbs(position) >= 0.01) return;          // current position
  if(GoLong && setup_rsi_01()) {
    Position *trade = new Position();
    int oneR = LookupStopPips(symbol);
    double stopLoss =  oneR * OnePoint;
    trade.LotSize = CalcTradeSize(account,stopLoss);
    trade.IsPending = true;
    trade.OpenPrice = iHigh(NULL,0,1);
    trade.OrderType = OP_BUYSTOP;
    trade.Symbol = symbol;
    trade.Reference = __FILE__;
    trade.Magic = magic.get("RSI",oneR);
    Debug("=====>Trade.magic="+string(trade.Magic));
    broker.CreateOrder(trade);
    if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
   // if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
  }
}
/*
  switch(SetupId) {
    case 0:
      side = trader.setup_crossOver01();
      if(side == 1 && GoLong) {
        oneRpips = riskMgr.initialStop(InitStopModel);
        rewardPips = riskMgr.profitTarget(oneR,ProfitTargetModel);
        if(rewardPips/oneRpips < MinReward2RiskRatio)
          continue
        trade = trader.entry_yellowLine(oneRpips,rewardPips,SetupId,EntryModel,YellowLineBarShift);
        if(trade)
          broker.CreateOrder(trade);
        enterLong01();  // yellow line entry. Pati pips initial stop, PATI levels target
      break;
    default:
  }
      
  }
}
*/


bool setup_rsi_01() {
  double rsi=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,0);
  double rsi1=iRSI(Symbol(),0,RSIperiod,PRICE_CLOSE,1);
  double BuyLevel=30;
  
  if(rsi>BuyLevel && rsi1<BuyLevel) return true;
  return false;
}

int Robo::barsSince(datetime from) {
  int bar = int((iTime(NULL,0,0) - from) / PeriodSeconds());
  return(bar);
} 

bool Robo::longSetup() {
  return true;
}

bool Robo::shortSetup() {
  return true;
}

bool Robo::isStartOfNewSession() {
  if(Time[0] >= session.startTradingSession_Server) {
    session.startTradingSession_Server = session.addDay(session.startTradingSession_Server);
    return true;
  }
  return false;
}