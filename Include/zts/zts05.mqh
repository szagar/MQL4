
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
//|                                                        zts05.mqh |
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
//|
//|       Initial Risk Model(1R):                                                           OneRmodel=1
//|               when: before trade setup                                                  OneRatrMultiplier=2.7
//|               1 : PATI static pips                                                      OneRatrPeriod=0
//|               2 : ATR(multiplier, ATRperiod, number periods)                            OneRatrNumPeriods=14
//|               3 : moving average(type,period,buffer pips)                               OneRmaType=EMA|SMA
//|                                                                                         OneRmaPeriod=10
//|                                                                                         OneRmaPlusPips=2
//|       Risk Model: 
//|         Stop Trading Model(1R): 
//|               when : before checking for new trades
//|               0/1 : no new trades if current real + unreal pnl is >                     MaxDailyRiskPips
//|               0/1 : no new trades if number of open positions >= N trades (ntrades=6)   MaxConcurrentPositions
//|         Risk Thresholds Model(1R): 
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
//|               1 : no trailing stop                                                    TrailingStopBarShift=1
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

extern string commentString_16 = "*****************************************";
extern string commentString_17 = "ROBO SETTINGS";
extern int RoboID = 1;
extern int MarketModel = 1;
extern bool CanPyramid = false;
//extern Enum_Sessions tradingSession = NewYork;
extern int EngulfingType = 1;
extern string ExitParams = "=== Exit Params ===";
extern int InitStopModel = 0;
//extern int TimeExitModel = 0;
//extern int ProfitExitModel = 0;
extern string SetupParams = "=== Setup Params ===";


extern bool Setup_BollingerBand = false;
#include <zts\BollingerBand.mqh>

extern bool Setup_Finch = true;
#include <zts\Finch.mqh>

extern bool Setup_MovingAvg = false;
#include <zts\MovingAvgCross.mqh>

extern bool Setup_Rsi = false;
#include <zts\Rsi.mqh>

extern string EntryParams = "=== Entry Params ===";
extern int SetupId = 0;
extern int EntryModel = 0;
extern int YellowLineBarShift = 1;

#include <zts\InitialRisk.mqh>
#include <zts\ExitManager.mqh>
#include <zts\Account.mqh>
#include <zts\Broker.mqh>
#include <zts\PositionSizer.mqh>
//#include <zts\position_sizing.mqh>
//#include <zts\TradingSessions.mqh>
#include <zts\MarketCondition.mqh>
//#include <zts\Trader.mqh>


extern string _dummy2 = "=== EquityManager Params ===";
extern int EquityModel = 1;
extern string commentString_18 = "***************************************** ROBO SETTINGS";

  int dayBarNumber;
  int sessionBarNumber;
  

class Robo {
private:
  bool pendingSetup;
  bool rangeIsSet;
  int exitStrats[5];
  int exitStratCnt;
  //int setupList[5];
  int totalPositions;
  double position;
  string symbol;
  
  Setup *longSetups[10];
  Setup *shortSetups[10];
  Setup *longSetupsOnTick[10];
  Setup *shortSetupsOnTick[10];
  Setup *longSetupsOnBar[10];
  Setup *shortSetupsOnBar[10];
  int longSetupCnt;
  int shortSetupCnt;
  int longSetupOnTickCnt;
  int shortSetupOnTickCnt;
  int longSetupOnBarCnt;
  int shortSetupOnBarCnt;
  double positionLong, positionShort;
  double posPendingLong, posPendingShort;

  
  ///int MagicNumber;
  bool useTrailingStop;

  double rangeLower, rangeUpper;
  InitialRisk *initRisk;
  ExitManager *exitMgr;
  Account *account;
  Broker *broker;
  PositionSizer *sizer;
  Describe *about;
  MagicNumber *magic;
  TradingSessions *session;
  MarketCondition *market;
  Trader *trader;
  
  void updateStopLoss(Position *);

  void initLongSetupStrategies();       //(Setup* &_longSetups[]);
  void initShortSetupStrategies();      //(Setup* &_shortSetups[]);
  void look2trade(Setup* &setups[],int);

  //void tradeLong();
  //void tradeShort();

  int barsSince(datetime);
  bool isStartOfNewSession();
  
public:
  //datetime startTradingSession_Server;
  datetime endTradingSession_Server;
  datetime startTradingDay_Server;
  datetime endTradingDay_Server;

  Robo();
  ~Robo();
  
  int OnInit();
  void OnDeinit();
  void OnTick();
  void OnNewBar();
  
  //void addSetup(int);
  void cleanUpEOD();
  void startOfDay();
  void handleOpenPositions();
  void updatePendingOrders();

  void checkForSetups();
  bool canTradeSymbol();
};

Robo::Robo() {
  pendingSetup = false;
  rangeIsSet = false;
  exitStratCnt = 0;
  initRisk = new InitialRisk();
  exitMgr = new ExitManager(ExitModel);
  account = new Account();
  broker = new Broker();
  sizer = new PositionSizer();
  about = new Describe();
  magic = new MagicNumber();
  market = new MarketCondition(MarketModel);
  session = new TradingSessions(TradingSession);
  trader = new Trader(exitMgr,initRisk);
  symbol = broker.NormalizeSymbol(Symbol());

  if(GoLong) initLongSetupStrategies();
  if(GoShort) initShortSetupStrategies();
}
  
Robo::~Robo() {
  Setup *setup;
  for(int i=0;i<longSetupOnTickCnt;i++) {
    setup = longSetupsOnTick[i];
    if (CheckPointer(setup) == POINTER_DYNAMIC) delete setup;
  }
  for(int i=0;i<longSetupOnBarCnt;i++) {
    setup = longSetupsOnBar[i];
    if (CheckPointer(setup) == POINTER_DYNAMIC) delete setup;
  }
  for(int i=0;i<shortSetupOnTickCnt;i++) {
    setup = shortSetupsOnTick[i];
    if (CheckPointer(setup) == POINTER_DYNAMIC) delete setup;
  }
  for(int i=0;i<shortSetupOnBarCnt;i++) {
    setup = shortSetupsOnBar[i];
    if (CheckPointer(setup) == POINTER_DYNAMIC) delete setup;
  }
  if (CheckPointer(initRisk) == POINTER_DYNAMIC) delete initRisk;
  if (CheckPointer(sizer) == POINTER_DYNAMIC) delete sizer;
  if (CheckPointer(trader) == POINTER_DYNAMIC) delete trader;
  if (CheckPointer(session) == POINTER_DYNAMIC) delete session;
  if (CheckPointer(market) == POINTER_DYNAMIC) delete market;
  if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
  if (CheckPointer(about) == POINTER_DYNAMIC) delete about;
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;
  if (CheckPointer(account) == POINTER_DYNAMIC) delete account;
  //if (CheckPointer(riskMgr) == POINTER_DYNAMIC) delete riskMgr;
  if (CheckPointer(exitMgr) == POINTER_DYNAMIC) delete exitMgr;
}

int Robo::OnInit() {
  session.setSession(TradingSession);
  session.setSession(NYSE);
  Debug(session.showSession());
  Debug(session.showSession(true));

  dayBarNumber = barsSince(session.startOfDay);
  sessionBarNumber = barsSince(session.startTradingSession_Server);
  Debug("Bars since: SOD: "+string(dayBarNumber) + "   Bars since: SOS: "+string(sessionBarNumber));
  
  Setup *setup;
  for(int i=0;i<longSetupOnTickCnt;i++) {
    setup = longSetupsOnTick[i];
    setup.OnInit();
  }
  for(int i=0;i<longSetupOnBarCnt;i++) {
    setup = longSetupsOnBar[i];
    setup.OnInit();
  }
  return(0);
}

void Robo::OnDeinit() { }

void Robo::OnTick() {
  //Debug4(__FUNCTION__,__LINE__,"Robo::OnTick");
  Setup *setup;
  for(int i=0;i<longSetupOnTickCnt;i++) {
    setup = longSetupsOnTick[i];
    setup.OnTick();
  }
  //Debug4(__FUNCTION__,__LINE__,"1");
  for(int i=0;i<shortSetupOnTickCnt;i++) {
    setup = shortSetupsOnTick[i];
    setup.OnTick();
  }
  //Debug4(__FUNCTION__,__LINE__,"2");
  //if(session.tradeWindow() && canTradeSymbol()) {
  if(true) {
    if(market.canGoLong())
      look2trade(longSetupsOnTick,longSetupOnTickCnt);
    if(market.canGoShort())
      look2trade(shortSetupsOnTick,shortSetupOnTickCnt);
  }
  //Debug4(__FUNCTION__,__LINE__,"3");
}

void Robo::OnNewBar() {   //bool tradeWindow) {
  Debug4(__FUNCTION__,__LINE__,DoubleToStr(positionLong,2)+" / "+DoubleToStr(positionShort,2)+
                                       " / "+DoubleToStr(posPendingLong,2)+" / "+DoubleToStr(posPendingShort,2));
  dayBarNumber++;
  sessionBarNumber++;
  if(isStartOfNewSession())
    sessionBarNumber = 1;

  handleOpenPositions();
  updatePendingOrders();

  Setup *setup;
  for(int i=0;i<longSetupOnTickCnt;i++) {
    setup = longSetupsOnTick[i];
    setup.OnTick();
  }
  for(int i=0;i<shortSetupOnTickCnt;i++) {
    setup = shortSetupsOnTick[i];
    setup.OnTick();
  }
  for(int i=0;i<longSetupOnBarCnt;i++) {
    setup = longSetupsOnBar[i];
    setup.OnBar();
  }
  for(int i=0;i<shortSetupOnBarCnt;i++) {
    setup = shortSetupsOnBar[i];
    setup.OnBar();
  }
  if(session.tradeWindow() && canTradeSymbol()) {
    if(market.canGoLong())
      look2trade(longSetupsOnTick,longSetupOnTickCnt);
    if(market.canGoShort())
      look2trade(shortSetupsOnTick,shortSetupOnTickCnt);
  }
}

void Robo::cleanUpEOD() { }

void Robo::startOfDay() { 
  Setup *setup;
  for(int i=0;i<longSetupCnt;i++) {
    setup = longSetups[i];
    setup.startOfDay();
  }
}

void Robo::handleOpenPositions() {
  //Debug("handleOpenPositions entered");
  int lastError = 0;
  Position *trade;
  totalPositions=0;
  position=0;
  for(int i=OrdersTotal()-1; i>=0; i--)  {
    if(!OrderSelect(i,SELECT_BY_POS)) {
      lastError = GetLastError();
      Warn("OrderSelect("+string(i)+", SELECT_BY_POS) - Error #"+string(lastError));
      continue;
    }
    trade = broker.GetPosition();
    if(StringCompare(OrderSymbol(),Symbol())==0 && magic.roboID(OrderMagicNumber()) == RoboID) {
      //if(StringCompare(magic.getStrategy(OrderMagicNumber()), "CDM-YL", false)!=0) continue;
      if(OrderType() == OP_BUY ) {
        totalPositions++;
        position += double(OrderLots());
        //if(TrailingStopModel != None)
        updateStopLoss(trade);
      }
    
      if(OrderType() == OP_SELL) {
        totalPositions++;
        position -= double(OrderLots());
        //if(TrailingStopModel != None)
        updateStopLoss(trade);
      }
    } else {
    }
    if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
  }
}

void Robo::updatePendingOrders() {
}

void Robo::updateStopLoss(Position *pos) {
  Debug4(__FUNCTION__,__LINE__,"Entered");
  double newStopLoss;
  Debug2("updateStopLoss entered:  side="+EnumToString(pos.Side)+"   oneR="+string(magic.getOneR(OrderMagicNumber())));
  //newStopLoss = exitMgr.getTrailingStop(pos);
  newStopLoss = trader.calcStopLoss(pos);

  if(newStopLoss > 0) {
    Debug4(__FUNCTION__,__LINE__,IntegerToString(OrderTicket())+" update stop loss: "+
                         DoubleToStr(OrderStopLoss(),Digits)+" => "+DoubleToStr(newStopLoss,Digits));
    broker.modifyStopLoss(OrderTicket(),newStopLoss);
  } else
    Debug4(__FUNCTION__,__LINE__,"DO NOT update trailing stop");
}


int Robo::barsSince(datetime from) {
  int bar = int((iTime(NULL,0,0) - from) / PeriodSeconds());
  return(bar);
} 

void Robo::initLongSetupStrategies() {       // (Setup* &_setups[]) {
  //int size=ArraySize(longSetups);
  int t_size=ArraySize(longSetupsOnTick);
  int b_size=ArraySize(longSetupsOnBar);
  int t_cnt = 0;
  int b_cnt = 0;
  Setup *setup;
  
  if(Setup_Finch) {
    Debug4(__FUNCTION__,__LINE__,"Add Finch Long Setup");
    setup = new Finch(symbol,Long);
    if(setup.callOnTick) longSetupsOnTick[t_cnt++] = setup;
    if(t_cnt==t_size) {
      ArrayResize(longSetupsOnTick, 2*t_size);
      t_size *= 2;
    }
    if(setup.callOnBar) longSetupsOnBar[b_cnt++] = setup;
    if(b_cnt==b_size) {
      ArrayResize(longSetupsOnBar, 2*b_size);
      b_size *= 2;
    }
  }

  if(Setup_BollingerBand) {
    Debug4(__FUNCTION__,__LINE__,"Add Bollinger Long Setup");
    setup = new BollingerBand(symbol,Long);   //Symbol(),Long,BollingerBandModel);
    if(setup.callOnTick) longSetupsOnTick[t_cnt++] = setup;
    if(t_cnt==t_size) {
      ArrayResize(longSetupsOnTick, 2*t_size);
      t_size *= 2;
    }
    if(setup.callOnBar) longSetupsOnBar[b_cnt++] = setup;
    if(b_cnt==b_size) {
      ArrayResize(longSetupsOnBar, 2*b_size);
      b_size *= 2;
    }
  }

  if(Setup_MovingAvg) {
    Debug4(__FUNCTION__,__LINE__,"Add MovingAvg Long Setup");
    setup = new MovingAvgCross(Symbol(),Long,MovingAvgLongModel);
    if(setup.callOnTick) longSetupsOnTick[t_cnt++] = setup;
    if(t_cnt==t_size) {
      ArrayResize(longSetupsOnTick, 2*t_size);
      t_size *= 2;
    }
    if(setup.callOnBar) longSetupsOnBar[b_cnt++] = setup;
    if(b_cnt==b_size) {
      ArrayResize(longSetupsOnBar, 2*b_size);
      b_size *= 2;
    }
  }

  if(Setup_Rsi) {
    Debug4(__FUNCTION__,__LINE__,"Add RSI Long Setup");
    setup = new Rsi(Symbol(),Long);
    if(setup.callOnTick) longSetupsOnTick[t_cnt++] = setup;
    if(t_cnt==t_size) {
      ArrayResize(longSetupsOnTick, 2*t_size);
      t_size *= 2;
    }
    if(setup.callOnBar) longSetupsOnBar[b_cnt++] = setup;
    if(b_cnt==b_size) {
      ArrayResize(longSetupsOnBar, 2*b_size);
      b_size *= 2;
    }
  }  
  longSetupOnTickCnt = t_cnt;
  longSetupOnBarCnt = b_cnt;
}

void Robo::initShortSetupStrategies() {       //(Setup* &_setups[]) {
  //int size=ArraySize(_setups);
  //int i = 0;
  int t_size=ArraySize(shortSetupsOnTick);
  int b_size=ArraySize(shortSetupsOnBar);
  int t_cnt = 0;
  int b_cnt = 0;
  Setup *setup;

  if(Setup_BollingerBand) {
    Debug4(__FUNCTION__,__LINE__,"Add Bollinger Short Setup");
    setup = new BollingerBand(symbol,Short);   //Symbol(),Long,BollingerBandModel);
    if(setup.callOnTick) shortSetupsOnTick[t_cnt++] = setup;
    if(t_cnt==t_size) {
      ArrayResize(shortSetupsOnTick, 2*t_size);
      t_size *= 2;
    }
    if(setup.callOnBar) shortSetupsOnBar[b_cnt++] = setup;
    if(b_cnt==b_size) {
      ArrayResize(shortSetupsOnBar, 2*b_size);
      b_size *= 2;
    }
  }

  if(Setup_MovingAvg) {
    Debug4(__FUNCTION__,__LINE__,"Add MovingAvg Short Setup");
    setup = new MovingAvgCross(Symbol(),Short,MovingAvgLongModel);
    if(setup.callOnTick) shortSetupsOnTick[t_cnt++] = setup;
    if(t_cnt==t_size) {
      ArrayResize(shortSetupsOnTick, 2*t_size);
      t_size *= 2;
    }
    if(setup.callOnBar) shortSetupsOnBar[b_cnt++] = setup;
    if(b_cnt==b_size) {
      ArrayResize(shortSetupsOnBar, 2*b_size);
      b_size *= 2;
    }
  }

  if(Setup_Rsi) {
    Debug4(__FUNCTION__,__LINE__,"Add RSI Short Setup");
    setup = new Rsi(Symbol(),Short);
    if(setup.callOnTick) shortSetupsOnTick[t_cnt++] = setup;
    if(t_cnt==t_size) {
      ArrayResize(shortSetupsOnTick, 2*t_size);
      t_size *= 2;
    }
    if(setup.callOnBar) shortSetupsOnBar[b_cnt++] = setup;
    if(b_cnt==b_size) {
      ArrayResize(shortSetupsOnBar, 2*b_size);
      b_size *= 2;
    }
  }  
  shortSetupOnTickCnt = t_cnt;
  shortSetupOnBarCnt = b_cnt; 
}

bool Robo::isStartOfNewSession() {
  if(Time[0] >= session.startTradingSession_Server) {
    session.startTradingSession_Server = session.addDay(session.startTradingSession_Server);
    return true;
  }
  return false;
}

void Robo::look2trade(Setup* &setups[],int size) {
  //Debug4(__FUNCTION__,__LINE__,"Entered");
  Position *trade;
  Setup *setup;
  for(int i=0;i<size;i++) {
    setup = setups[i];
    if(setup.triggered) {
      trade = trader.newTrade(setup);
      setup.reset();
      if(trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
        Info("Trade did not meet min reward-to-risk ratio");
        if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
        continue;
      }
      Info(__FUNCTION__+": T R A D E Long:  "+trade.toHuman());
      broker.CreateOrder(trade);
      if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
    }
  }
}

/**
void Robo::tradeShort() {
  Position *trade;
  Setup *setup;
  for(int i=0;i<shortSetupCnt;i++) {
    setup = shortSetups[i];
    if(setup.triggered()) {
      trade = trader.newTrade(setup);
      broker.CreateOrder(trade);
      if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
    }
      //Info(__FUNCTION__+": T R A D E Short:  "+trade.toHuman());
    //}
  }
}
**/

bool Robo::canTradeSymbol() {
  bool possiblePos = false;
  
  positionLong=0;
  positionShort=0;
  posPendingLong=0;
  posPendingShort=0;
  
  if(CanPyramid) return true;
  
  for(int i=OrdersTotal()-1; i>=0; i--)  {
    if(!OrderSelect(i,SELECT_BY_POS)) {
      int lastError = GetLastError();
      Warn("OrderSelect("+string(i)+", SELECT_BY_POS) - Error #"+string(lastError));
      continue;
    }
    if(OrderSymbol() != Symbol()) continue;
    if(magic.roboID(OrderMagicNumber()) != RoboID) continue;
    
    possiblePos = true;
    
    int otype = OrderType();
    if(otype == OP_BUY )
      positionLong += OrderLots();
    if(otype == OP_SELL)
      positionShort += OrderLots();
    if(otype == OP_SELLLIMIT || otype == OP_SELLSTOP)
      positionShort += OrderLots();
    if(otype == OP_BUYLIMIT || otype == OP_BUYSTOP)
      positionShort += OrderLots();
  }
  if(possiblePos && !CanPyramid) return false;
  return true;
}

