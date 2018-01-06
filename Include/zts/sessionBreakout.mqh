
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
//|                                                        sessionBreakout.mqh |
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

extern string RoboParams = "=== Robo Params ===";
extern int RoboID = 1;
extern int MarketModel = 1;
extern bool CanPyramid = false;

extern int EngulfingType = 1;
extern string ExitParams = "=== Exit Params ===";
extern int InitStopModel = 0;
//extern int TrailingStopModel = 0;
//extern int TimeExitModel = 0;
//extern int ProfitExitModel = 0;
extern string SetupParams = "=== Setup Params ===";
extern bool Setup_MovingAvgLong = true;
extern int MovingAvgLongModel = 1;
extern bool Setup_MovingAvgShort = true;
extern int MovingAvgShortModel = 1;

extern bool Setup_BollingerBand = true;
extern int BollingerBandModel = 1;
extern bool Setup_BollingerBandLong = true;
extern bool Setup_BollingerBandShort = true;
#include <zts\BollingerBand.mqh>

extern bool Setup_RsiLong = true;
extern bool Setup_RsiShort = true;
extern string EntryParams = "=== Entry Params ===";
extern int SetupId = 0;
extern int EntryModel = 0;
extern int YellowLineBarShift = 1;
extern int RSIperiod = 3;

#include <zts\RiskManager.mqh>
#include <zts\Account.mqh>
#include <zts\Broker.mqh>
#include <zts\PositionSizer.mqh>
#include <zts\InitialRisk.mqh>
#include <zts\position_sizing.mqh>
#include <zts\TradingSessions.mqh>
#include <zts\MarketCondition.mqh>
#include <zts\Trader.mqh>

#include <zts\MovingAvgCross.mqh>
#include <zts\Rsi.mqh>

extern string _dummy2 = "=== EquityManager Params ===";
extern int EquityModel = 1;

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
  int longSetupCnt;
  int shortSetupCnt;
  double positionLong, positionShort;
  double posPendingLong, posPendingShort;

  
  ///int MagicNumber;
  bool useTrailingStop;

  double rangeLower, rangeUpper;
  RiskManager *riskMgr;
  Account *account;
  Broker *broker;
  PositionSizer *sizer;
  InitialRisk *initRisk;
  Describe *about;
  MagicNumber *magic;
  TradingSessions *session;
  MarketCondition *market;
  Trader *trader;
  
  void updateStopLoss(Position *);

  int initLongSetupStrategies(Setup* &_longSetups[]);
  int initShortSetupStrategies(Setup* &_shortSetups[]);
  void tradeLong();
  void tradeShort();

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
  riskMgr = new RiskManager(EquityModel,RiskModel);
  account = new Account();
  broker = new Broker();
  sizer = new PositionSizer();
  initRisk = new InitialRisk();
  about = new Describe();
  magic = new MagicNumber();
  market = new MarketCondition(MarketModel);
  session = new TradingSessions(tradingSession);
  trader = new Trader();
  symbol = broker.NormalizeSymbol(Symbol());

  longSetupCnt = initLongSetupStrategies(longSetups);
  shortSetupCnt = initShortSetupStrategies(shortSetups);
}
  
Robo::~Robo() {
  Setup *setup;
  for(int i=0;i<longSetupCnt;i++) {
    setup = longSetups[i];
    if (CheckPointer(setup) == POINTER_DYNAMIC) delete setup;
  }
  for(int i=0;i<shortSetupCnt;i++) {
    setup = shortSetups[i];
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
  if (CheckPointer(riskMgr) == POINTER_DYNAMIC) delete riskMgr;
}

int Robo::OnInit() {
  session.setSession(tradingSession);
  session.setSession(NYSE);
  Debug(session.showSession());
  Debug(session.showSession(true));

  dayBarNumber = barsSince(session.startOfDay);
  sessionBarNumber = barsSince(session.startTradingSession_Server);
  Debug("Bars since: SOD: "+string(dayBarNumber) + "   Bars since: SOS: "+string(sessionBarNumber));
  return(0);
}

void Robo::OnDeinit() { }

void Robo::OnTick() {
  Debug4(__FUNCTION__,__LINE__,"Robo::OnTick");
  Setup *setup;
  for(int i=0;i<longSetupCnt;i++) {
    setup = longSetups[i];
    setup.OnTick();
  }
}

void Robo::OnNewBar() {   //bool tradeWindow) {
  Debug4(__FUNCTION__,__LINE__,DoubleToStr(positionLong,2)+" / "+DoubleToStr(positionShort,2)+
                                       " / "+DoubleToStr(posPendingLong,2)+" / "+DoubleToStr(posPendingShort,2));
  dayBarNumber++;
  sessionBarNumber++;
  if(isStartOfNewSession())
    sessionBarNumber = 1;

  //Info(TimeToString(Time[0])+"Bars since: SOD: "+string(dayBarNumber) + "   Bars since: SOS: "+string(sessionBarNumber));
  
  handleOpenPositions();
  updatePendingOrders();
  //Setup setups[];
  //Debug stuff
  if(!canTradeSymbol()) Debug4(__FUNCTION__,__LINE__,"Cannot trade symbol");
  if(session.tradeWindow() && canTradeSymbol()) {
    if(market.canGoLong()) {
      Debug1("tradeLong");
      tradeLong();
    }
    if(market.canGoShort()) {
      Debug1("tradeShort");
      tradeShort();
    }
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
  Debug("handleOpenPositions entered");
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
    if(StringCompare(OrderSymbol(),Symbol())==0 && magic.roboID() == RoboID) {
      Debug4(__FUNCTION__,__LINE__,"Type: "+IntegerToString(OrderType())+" ID: "+IntegerToString(OrderTicket())+"  "+OrderSymbol()+" "+DoubleToStr(OrderLots(),2)+" magic:"+IntegerToString(OrderMagicNumber()));
      Debug4(__FUNCTION__,__LINE__,symbol+": Strategy="+magic.getStrategy(OrderMagicNumber())+"  magic="+string(OrderMagicNumber()));
      //if(StringCompare(magic.getStrategy(OrderMagicNumber()), "CDM-YL", false)!=0) continue;
      if(OrderType() == OP_BUY ) {
        totalPositions++;
        position += double(OrderLots());
        if(TrailingStopModel != NA)
          updateStopLoss(trade);
      }
    
      if(OrderType() == OP_SELL) {
        totalPositions++;
        position -= double(OrderLots());
        if(TrailingStopModel != NA)
          updateStopLoss(trade);
      }
      Debug4(__FUNCTION__,__LINE__,"Total Position="+IntegerToString(totalPositions)+"  Position="+DoubleToString(position,2));
    } else {
      Debug4(__FUNCTION__,__LINE__,"Open trade did not match Symbol and Magic Number");
      Debug4(__FUNCTION__,__LINE__,"Type: "+IntegerToString(OrderType())+" ID: "+IntegerToString(OrderTicket())+"  "+OrderSymbol()+" "+DoubleToStr(OrderLots(),2)+" magic:"+IntegerToString(OrderMagicNumber()));
      Debug4(__FUNCTION__,__LINE__,symbol+": Strategy="+magic.getStrategy(OrderMagicNumber())+"  magic="+string(OrderMagicNumber()));
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
  newStopLoss = riskMgr.getTrailingStop(pos);

  if(newStopLoss > 0) {
    Debug4(__FUNCTION__,__LINE__,IntegerToString(OrderTicket())+" update stop loss: "+
                         DoubleToStr(OrderStopLoss(),Digits)+" => "+DoubleToStr(newStopLoss,Digits));
    broker.modifyStopLoss(OrderTicket(),newStopLoss);
  } else
    Debug4(__FUNCTION__,__LINE__,"DO NOT update trailing stop");
}

/*
//void Robo::checkForSetups(void) {
//  Debug("checkForSetups entered");
//  if(MathAbs(position) >= 0.01) return;          // current position
//  if(GoLong && setup_rsi_01()) {
//    Position *trade = new Position();
//    int oneR = LookupStopPips(symbol);
//    double stopLoss =  oneR * OnePoint;
//    trade.LotSize = CalcTradeSize(account,stopLoss);
//    trade.IsPending = true;
//    trade.OpenPrice = iHigh(NULL,0,1);
//    trade.OrderType = OP_BUYSTOP;
//    trade.Symbol = symbol;
//    trade.Reference = __FILE__;
//    trade.Magic = magic.get("RSI",oneR);
//    Debug("=====>Trade.magic="+string(trade.Magic));
//    broker.CreateOrder(trade);
//    if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
//   // if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
//  }
//}
*/

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

int Robo::initLongSetupStrategies(Setup* &_setups[]) {
  int size=ArraySize(_setups);
  int i = 0;
  //Position *trade;
  
  if(Setup_BollingerBandLong) {
    Debug4(__FUNCTION__,__LINE__,"Add Bollinger Long Setup");
    _setups[i++] = new BollingerBand(symbol,Long);   //Symbol(),Long,BollingerBandModel);
    if(i==size) {
      ArrayResize(_setups, 2*size);
      size *= 2;
    }
  }

  if(Setup_MovingAvgLong) {
    Debug4(__FUNCTION__,__LINE__,"Add MovingAvg Long Setup");
    _setups[i++] = new MovingAvgCross(Symbol(),Long,MovingAvgLongModel);
    if(i==size) {
      ArrayResize(_setups, 2*size);
      size *= 2;
    }
  }

  if(Setup_RsiLong) {
    Debug4(__FUNCTION__,__LINE__,"Add RSI Long Setup");
    _setups[i++] = new Rsi(Symbol(),Long);
    if(i==size) {
      ArrayResize(_setups, 2*size);
      size *= 2;
    }
  }
  
  //for(i=0;i<setupCnt;i++) {
  //  Info("Setup: "+EnumToString(_setups[i].side)+"  "+_setups[i].name);
  //}
  return(i);
}

int Robo::initShortSetupStrategies(Setup* &_setups[]) {
  int size=ArraySize(_setups);
  int i = 0;
  
  if(Setup_BollingerBandShort) {
    Debug4(__FUNCTION__,__LINE__,"Add Bollinger Short Setup");
    _setups[i++] = new BollingerBand(symbol,Short);    //Symbol(),Short,BollingerBandModel);
    if(i==size) {
      ArrayResize(_setups, 2*size);
      size *= 2;
    }
  }

  if(Setup_MovingAvgShort) {
    Debug4(__FUNCTION__,__LINE__,"Add MovingAvg Short Setup");
    _setups[i++] = new MovingAvgCross(Symbol(),Short,MovingAvgShortModel);
    if(i==size) {
      ArrayResize(_setups, 2*size);
      size *= 2;
    }
  }

  if(Setup_RsiShort) {
    Debug4(__FUNCTION__,__LINE__,"Add RSI Short Setup");
    _setups[i++] = new Rsi(Symbol(),Short);
    if(i==size) {
      ArrayResize(_setups, 2*size);
      size *= 2;
    }
  }

  //for(i=0;i<setupCnt;i++) {
  //  Info("Setup: "+EnumToString(_setups[i].side)+"  "+_setups[i].name);
  //}
  return(i);
}

bool Robo::isStartOfNewSession() {
  if(Time[0] >= session.startTradingSession_Server) {
    session.startTradingSession_Server = session.addDay(session.startTradingSession_Server);
    return true;
  }
  return false;
}

void Robo::tradeLong() {
  Position *trade;
  Setup *setup;
  for(int i=0;i<longSetupCnt;i++) {
    setup = longSetups[i];
    if(setup.triggered()) {
      trade = trader.newTrade(setup);
      //broker.CreateOrder(trade);
      Debug4(__FUNCTION__,__LINE__,"Reward2Risk="+DoubleToStr(trade.RewardPips/trade.OneRpips,4));
      if(trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
        Info("Trade did not meet min reward-to-risk ratio");
        if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
        continue;
      }
      Info(__FUNCTION__+": T R A D E Long:  "+trade.toHuman());
      broker.CreateOrder(trade);
      if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
    }
    //Info(__FUNCTION__+": "+string(i)+"  "+EnumToString(setup.side)+"  "+setup.name);
  }
}

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
    if(magic.roboID() != RoboID) continue;
    
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

