
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
//|                                                        zts03.mqh |
//|   Trade bullish engulfing after n closing down days.             |
//|   Enter on high of engulfing bar
//|   Trade only during specified sessions.                          |
//|   One R is 1.5 x ATR5                                            |
//|   Exits: trailing stop of previous bar low                       |
//|          after 5 bars if profit < 1ATR
//|   Notes: engulfing type  1: engulfs body
//|                          2: engulfs candle
//|                          3: engulfs body & wick
//|                          4: engulfs body & tail
//|          session   1: London
//|                    2: New York
//|                    3: Asia
//|                    4: London close
//+------------------------------------------------------------------+
#property strict

#include <zts\common.mqh>
#include <zts\MagicNumber.mqh>


extern string RoboParams = "=== Robo Params ===";
extern int TradingSession = 2;
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
  
  ///int MagicNumber;
  bool useTrailingStop;

  double rangeLower, rangeUpper;
  RiskManager *riskMgr;
  Account *account;
  Broker *broker;
  Describe *about;
  MagicNumber *magic;
  
  void updateStop(string,int);

  //void checkForSetups();
  //void newYellowLine(string);
  //void setRangeForSession(string);
  //void setRange(datetime, datetime, datetime&[], double&[], double&[]); 
  void setSessionTime(); 
  //void setExitStrategy(int);
  //void configExitStrategies();
public:
  datetime startTradingSession_GMT;
  datetime endTradingSession_GMT;

  Robo();
  ~Robo();
  
  int OnInit();
  void OnDeinit();
  void OnTick(bool=false);
  void OnNewBar(bool=false);
  
  //void addSetup(int);
  void cleanUpEOD();
  void startOfDay();
  void handleOpenPositions();

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
  symbol = broker.NormalizeSymbol(Symbol());
  //MagicNumber = 1234;
}
  
Robo::~Robo() {
  if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
  if (CheckPointer(about) == POINTER_DYNAMIC) delete about;
  if (CheckPointer(broker) == POINTER_DYNAMIC) delete broker;
  if (CheckPointer(account) == POINTER_DYNAMIC) delete account;
  if (CheckPointer(riskMgr) == POINTER_DYNAMIC) delete riskMgr;
}

int Robo::OnInit() {
  setSessionTime();
  //configExitStrategies();
  return(0);
}

void Robo::OnDeinit() { }
void Robo::OnTick(bool tradeWindow) { }

void Robo::OnNewBar(bool tradeWindow) {
  Debug(" Robo::OnNewBar("+string(tradeWindow)+")");
  handleOpenPositions();
  if(tradeWindow) checkForSetups();
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
void Robo::setRangeForSession(string sessionName) {
  datetime TimeCopy[];
  ArrayCopy(TimeCopy, Time, 0, 0, WHOLE_ARRAY);
  double HighPrices[];
  ArrayCopy(HighPrices, High, 0, 0, WHOLE_ARRAY);
  double LowPrices[];
  ArrayCopy(LowPrices, Low, 0, 0, WHOLE_ARRAY);
  datetime startTime, endTime;

  startTime = TimeCopy[10];
  endTime =  TimeCopy[0];
  
  if(sessionName=="Asian") {
    startTime = TimeCopy[10];
    endTime = TimeCopy[0];
  } else if(sessionName=="London") {
    startTime = TimeCopy[10];
    endTime = TimeCopy[0];
  } else if(sessionName=="NewYork") {
    startTime = TimeCopy[10];
    endTime =  TimeCopy[0];
  }
  setRange(startTime, endTime, TimeCopy, HighPrices, LowPrices);
}
*/

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

void Robo::setSessionTime() {
  MqlDateTime dtStruct;
  TimeToStruct(TimeCurrent(), dtStruct);
  dtStruct.hour = 0;
  dtStruct.min = 0;
  dtStruct.sec = 0;
  // GMT time zone
  startTradingSession_GMT = StructToTime(dtStruct) + 9*60*60 - TimeGMTOffset();
  startTradingSession_GMT = StructToTime(dtStruct) + 1*60*60 - TimeGMTOffset();
  endTradingSession_GMT = StructToTime(dtStruct) + 16*60*60 - TimeGMTOffset();
  Alert("startTradingSession_GMT=",startTradingSession_GMT);
  Alert("endTradingSession_GMT=",endTradingSession_GMT);
  switch(TradingSession) {
    case 1:   // London 
      //startTradingSession_GMT = ;
      //endTradingSession_GMT = ;
      break;
    case 2:   // New York
      break;
    case 3:   // Asia
      break;
    case 4:   // London close
      break;
    default:
      Warn(__FUNCTION__+": sesson ID unknown.");
  }
}

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
    if (CheckPointer(magic) == POINTER_DYNAMIC) delete magic;
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