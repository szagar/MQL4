#property strict

enum Enum_CP_MODELS {
  CP_BIG_SHADOW,            // fxjake Big Shadow
};

#include <dev\common.mqh>
#include <dev\MagicNumber.mqh>
#include <dev\TradingSessions.mqh>

extern string commentString_rp0 = ""; //--------------------------------------------
extern string commentString_rp1 = ""; //-------- CandleStick Patterns Robot --------
extern string commentString_rp2 = ""; //--------------------------------------------
extern string commentString_rp4 = ""; //*** Robot settings:
extern int RoboID = 3;                 //- robot ID
extern bool CanPyramid = false;        //- can pyramid ?

extern string commentString_rp5 = "";     //>>  Setups
extern Enum_CP_MODELS CP_Model = CP_BIG_SHADOW;
extern bool UseDefaultParameters = true; // Use pre-configured parameters for pattern
extern bool CP_Optimize = true;
#include <dev\CandlePatterns.mqh>


#include <dev\Trader.mqh>

#include <dev\InitialRisk.mqh>
#include <dev\ExitManager.mqh>
#include <dev\EntryModels.mqh>
#include <dev\ProfitTargetModels.mqh>

#include <dev\MarketModel.mqh>

#include <dev\Account.mqh>
#include <dev\Broker.mqh>
#include <dev\PositionSizer.mqh>

#include<dev/notify.mqh>



int barNumber;
int dayBarNumber;
int sessionBarNumber;
  
//int D2P;
///double P2D;

class Robo {
private:
  bool pendingSetup;
  bool rangeIsSet;
  int exitStrats[5];
  int exitStratCnt;
  int totalPositions;
  double position;
  string symbol;
  
  Setup *longSetups[10];
  Setup *shortSetups[10];
  Setup *longSetupsOnTick[10];
  Setup *shortSetupsOnTick[10];
  Setup *longSetupsOnBar[10];
  Setup *shortSetupsOnBar[10];

  int shortSetupCnt;
  int longSetupOnTickCnt;
  int shortSetupOnTickCnt;
  int longSetupOnBarCnt;
  int shortSetupOnBarCnt;
  double positionLong, positionShort;
  double posPendingLong, posPendingShort;

  
  ///int MagicNumber;

  double rangeLower, rangeUpper;
  InitialRisk *initRisk;
  ExitManager *exitMgr;
  EntryModels *entry;
  ProfitTargetModels *profitTgt;
  Account *account;
  Broker *broker;
  PositionSizer *sizer;
  //Describe *about;
  MagicNumber *magic;
  TradingSessions *session;
  MarketModel *market;
  Trader *trader;
  
  void updateStopLoss(Position *);

  void initLongSetupStrategies();       //(Setup* &_longSetups[]);
  void initShortSetupStrategies();      //(Setup* &_shortSetups[]);
  void addLongSetup(Setup*);
  void addShortSetup(Setup*);

  void checkTriggeredSetups(Setup* &setups[],int);

  //void tradeLong();
  //void tradeShort();

  int barsSince(datetime);
  bool isStartOfNewSession();
  
public:
  //datetime startTradingSession_Server;
  datetime endTradingSession_Server;
  datetime startTradingDay_Server;
  datetime endTradingDay_Server;

  Robo(TradingSessions*);
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

Robo::Robo(TradingSessions *_session=NULL) {
  if(_session == NULL) _session = new TradingSessions(TradingSession);
  session = _session;
  pendingSetup = false;
  rangeIsSet = false;
  exitStratCnt = 0;
  initRisk = new InitialRisk();
  exitMgr = new ExitManager();
  entry = new EntryModels();
  profitTgt = new ProfitTargetModels();
  account = new Account();
  broker = new Broker();
  sizer = new PositionSizer();
  //about = new Describe();
  magic = new MagicNumber();
  market = new MarketModel();
  trader = new Trader(exitMgr,initRisk,profitTgt);
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
  //if (CheckPointer(session) == POINTER_DYNAMIC) delete session;
  if (CheckPointer(market) == POINTER_DYNAMIC) delete market;
  if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
  //if (CheckPointer(about) == POINTER_DYNAMIC) delete about;
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;
  if (CheckPointer(account) == POINTER_DYNAMIC) delete account;
  //if (CheckPointer(riskMgr) == POINTER_DYNAMIC) delete riskMgr;
  if (CheckPointer(exitMgr) == POINTER_DYNAMIC) delete exitMgr;
  if (CheckPointer(entry) == POINTER_DYNAMIC) delete entry;
  if (CheckPointer(profitTgt) == POINTER_DYNAMIC) delete profitTgt;
}

int Robo::OnInit() {
//  D2P = (StringFind(Symbol(),"JPY",0)>0 ? 100 : 10000);
//  P2D = 1.0/D2P;
  Debug(__FUNCTION__,__LINE__,session.showSession());
  Debug(__FUNCTION__,__LINE__,session.showSession(true));

  barNumber = 1;
  dayBarNumber = barsSince(session.startOfDay);
  Info(__FUNCTION__+": set dayBarNumber to "+dayBarNumber);
  sessionBarNumber = barsSince(session.startTradingSession_Server);
  Debug(__FUNCTION__,__LINE__,"Bars since: SOD: "+string(dayBarNumber) + "   Bars since: SOS: "+string(sessionBarNumber));
  
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
  //Debug(__FUNCTION__,__LINE__,"Robo::OnTick");
  Setup *setup;
  for(int i=0;i<longSetupOnTickCnt;i++) {
    setup = longSetupsOnTick[i];
    setup.OnTick();
  }
  //Debug(__FUNCTION__,__LINE__,"1");
  for(int i=0;i<shortSetupOnTickCnt;i++) {
    setup = shortSetupsOnTick[i];
    setup.OnTick();
  }
  //Debug(__FUNCTION__,__LINE__,"2");
  if(session.tradeWindow(TradingSession) && canTradeSymbol()) {
    if(market.canGoLong())
      checkTriggeredSetups(longSetupsOnTick,longSetupOnTickCnt);
    if(market.canGoShort())
      checkTriggeredSetups(shortSetupsOnTick,shortSetupOnTickCnt);
  }
  //Debug(__FUNCTION__,__LINE__,"3");
}

void Robo::OnNewBar() {   //bool tradeWindow) {
  barNumber++;
  dayBarNumber++;
  sessionBarNumber++;
  if(isStartOfNewSession())
    sessionBarNumber = 1;

  handleOpenPositions();
  updatePendingOrders();

  Setup *setup;
  if(session.tradeWindow(TradingSession) && canTradeSymbol()) {
    if(GoLong) {
      for(int i=0;i<longSetupOnBarCnt;i++) {
        setup = longSetupsOnBar[i];
        setup.OnBar();
      }
    }
    if(GoShort) {
      for(int i=0;i<shortSetupOnBarCnt;i++) {
        setup = shortSetupsOnBar[i];
        setup.OnBar();
      }
    }
    if(market.canGoLong())
      checkTriggeredSetups(longSetupsOnBar,longSetupOnBarCnt);
    if(market.canGoShort())
      checkTriggeredSetups(shortSetupsOnBar,shortSetupOnBarCnt);
  }
}

void Robo::cleanUpEOD() { }

void Robo::startOfDay() {
  Debug(__FUNCTION__,__LINE__,"Entered"); 
  dayBarNumber = 1;
  Setup *setup;
  //for(int i=0;i<longSetupCnt;i++) {
  //  setup = longSetups[i];
  //  setup.startOfDay();
  //}
  
  if(GoLong) {
    for(int i=0;i<longSetupOnBarCnt;i++) {
      setup = longSetupsOnBar[i];
      setup.startOfDay();
    }
  }
  if(GoShort) {
    for(int i=0;i<shortSetupOnBarCnt;i++) {
      setup = shortSetupsOnBar[i];
      setup.startOfDay();
    }
  }
}

void Robo::handleOpenPositions() {
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
    if(StringCompare(OrderSymbol(),Symbol())==0) {  // &&
       //magic.roboID(OrderMagicNumber()) == RoboID) {
      if(OrderType() == OP_BUY ) {
        totalPositions++;
        position += double(OrderLots());
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
  Debug(__FUNCTION__,__LINE__,"Entered");
  double newStopLoss;
  Debug(__FUNCTION__,__LINE__,"updateStopLoss entered:  side="+EnumToString(pos.Side)+
         "   oneR="+string(magic.getOneR(OrderMagicNumber())));
  //newStopLoss = exitMgr.getTrailingStop(pos);
  newStopLoss = trader.calcStopLoss(pos);

  if(newStopLoss > 0) {
    Info("Update StopLoss: "+OrderType()+" "+IntegerToString(OrderTicket())+" "+
                         DoubleToStr(OrderStopLoss(),Digits)+" => "+DoubleToStr(newStopLoss,Digits));
    broker.modifyStopLoss(OrderTicket(),newStopLoss);
  } else
    Debug(__FUNCTION__,__LINE__,"DO NOT update trailing stop");
}


int Robo::barsSince(datetime from) {
  int bar = int((iTime(NULL,0,0) - from) / PeriodSeconds());
  return(bar);
} 

void Robo::initLongSetupStrategies() {
  Setup *setup;
  
  setup = new CandlePatterns(Long);
  addLongSetup(setup);  
}

void Robo::initShortSetupStrategies() {
  Setup *setup;

  setup = new CandlePatterns(Short);
  addShortSetup(setup);  
}

void Robo::addLongSetup(Setup *setup) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  int t_size=ArraySize(longSetupsOnTick);
  int b_size=ArraySize(longSetupsOnBar);
  Debug(__FUNCTION__,__LINE__,setup.strategyName+": t_size="+IntegerToString(t_size)+"  b_size="+IntegerToString(b_size));
  Debug(__FUNCTION__,__LINE__,setup.strategyName+": longSetupOnTickCnt="+IntegerToString(longSetupOnTickCnt)+"  longSetupOnBarCnt="+IntegerToString(longSetupOnBarCnt));
  Debug(__FUNCTION__,__LINE__,setup.strategyName+": callOnTick="+setup.callOnTick+"  callOnBar="+setup.callOnBar);

  if(setup.callOnTick) longSetupsOnTick[longSetupOnTickCnt++] = setup;
  if(longSetupOnTickCnt==t_size) {
    ArrayResize(longSetupsOnTick, 2*t_size);
    t_size=ArraySize(shortSetupsOnTick);
  }
  if(setup.callOnBar) longSetupsOnBar[longSetupOnBarCnt++] = setup;
  if(longSetupOnBarCnt==b_size) {
    ArrayResize(longSetupsOnBar, 2*b_size);
    b_size=ArraySize(longSetupsOnBar);
  }
  Debug(__FUNCTION__,__LINE__,setup.strategyName+": longSetupOnTickCnt="+IntegerToString(longSetupOnTickCnt)+"  longSetupOnBarCnt="+IntegerToString(longSetupOnBarCnt));
}

void Robo::addShortSetup(Setup *setup) {
  int t_size=ArraySize(shortSetupsOnTick);
  int b_size=ArraySize(shortSetupsOnBar);

  if(setup.callOnTick) shortSetupsOnTick[shortSetupOnTickCnt++] = setup;
  if(shortSetupOnTickCnt==t_size) {
    ArrayResize(shortSetupsOnTick, 2*t_size);
    t_size=ArraySize(shortSetupsOnTick);
  }
  if(setup.callOnBar) shortSetupsOnBar[shortSetupOnBarCnt++] = setup;
  if(shortSetupOnBarCnt==b_size) {
    ArrayResize(shortSetupsOnBar, 2*b_size);
    b_size=ArraySize(shortSetupsOnBar);
  }
}

bool Robo::isStartOfNewSession() {
  if(Time[0] >= session.startTradingSession_Server) {
    session.startTradingSession_Server = session.addDay(session.startTradingSession_Server);
    return true;
  }
  return false;
}

void Robo::checkTriggeredSetups(Setup* &setups[],int size) {
  //Debug(__FUNCTION__,__LINE__,"Entered, size="+string(size));
  Position *trade;
  Setup *setup;
  for(int i=0;i<size;i++) {
    setup = setups[i];
    if(setup.triggered) {
      Info("Setup triggered "+TimeToStr(TimeCurrent()));
      Debug(__FUNCTION__,__LINE__,"Setup triggered");

      if(ReverseLongShort) setup.side *= -1;
      if(entry.signaled(setup)) {
        Info("Entry triggered "+TimeToStr(TimeCurrent()));
        Info("Side Reversed.");
        Debug(__FUNCTION__,__LINE__,"Entry signaled");
        trade = trader.newTrade(setup);
        Info("New trade created: "+trade.toHuman());
        setup.reset();
        if(trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
          Info("Trade did not meet min reward-to-risk ratio");
          if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
          continue;
        }
        Info("Send Trade: "+trade.toHuman());
        broker.CreateOrder(trade);
        if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
      }
    }
  }
}

bool Robo::canTradeSymbol() {
  //Debug(__FUNCTION__,__LINE__,"Entered");
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
    //if(magic.roboID(OrderMagicNumber()) != RoboID) continue;
    
    possiblePos = true;
    
    int otype = OrderType();
    if(otype == OP_BUY )
      positionLong += OrderLots();
    if(otype == OP_SELL)
      positionShort += OrderLots();
    if(otype == OP_SELLLIMIT || otype == OP_SELLSTOP)
      positionShort += OrderLots();
    if(otype == OP_BUYLIMIT || otype == OP_BUYSTOP)
      positionLong += OrderLots();
  }
  //Debug(__FUNCTION__,__LINE__,"positionLong="+string(positionLong)+"  positionShort="+string(positionShort));
  //Debug(__FUNCTION__,__LINE__,"possiblePos="+string(possiblePos)+"  CanPyramid="+string(CanPyramid));
  if(possiblePos && !CanPyramid) return false;
  return true;
}

