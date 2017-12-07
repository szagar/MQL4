
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

#include <zts\RiskManager.mqh>
#include <zts\Account.mqh>
#include <zts\Broker.mqh>

extern string _dummy2 = "=== EquityManager Params ===";
extern int EquityModel = 1;

class Robo {
private:
  bool pendingSetup;
  bool rangeIsSet;
  int exitStrats[5];
  int exitStratCnt;
  int setupList[5];
  int setupCnt;
  ///int MagicNumber;
  bool useTrailingStop;

  double rangeLower, rangeUpper;
  RiskManager *riskMgr;
  Account *account;
  Broker *broker;
  Describe *about;
  MagicNumber *magic;
  
  void updateTrailingStop(string,int);

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
  void OnTick();
  void OnNewBar();
  
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
  setupCnt = 0;
  riskMgr = new RiskManager(EquityModel,RiskModel);
  account = new Account();
  broker = new Broker();
  about = new Describe();
  magic = new MagicNumber();
  //MagicNumber = 1234;
}
  
Robo::~Robo() {
 }

int Robo::OnInit() {
  setSessionTime();
  //configExitStrategies();
  return(0);
}

void Robo::OnDeinit() { }
void Robo::OnTick() { }

void Robo::OnNewBar() {
  Debug(" Robo::OnNewBar()");
  handleOpenPositions();
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
  startTradingSession_GMT = StructToTime(dtStruct) + 9*60*60 + TimeGMTOffset();
  endTradingSession_GMT = StructToTime(dtStruct) + 16*60*60 + TimeGMTOffset();
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
  Debug("handleOpenPositions entered");
  Debug("OrdersTotal()="+OrdersTotal());
  for(int i=OrdersTotal()-1; i>=0; i--)  {
    Debug("i="+i);
    if(!OrderSelect(i,SELECT_BY_POS)) {
      lastError = GetLastError();
      Warn("OrderSelect("+string(i)+", SELECT_BY_POS) - Error #"+string(lastError));
      continue;
    }
    if(OrderSymbol() != Symbol()) continue;
    Debug(Symbol()+": Strategy="+magic.getStrategy(OrderMagicNumber())+"  magic="+OrderMagicNumber());
    if(StringCompare(magic.getStrategy(OrderMagicNumber()), "CDM", false)!=0) continue;
    Debug("OK next");
    if(OrderType() == OP_BUY ) {
      if(true) useTrailingStop = true;
      int oneR = magic.getOneR(OrderMagicNumber());
      Debug("handleOpenPositions: oneR="+oneR);
      if(useTrailingStop) 
        updateTrailingStop("Long",magic.getOneR(OrderMagicNumber()));
    }
    
    if(OrderType() == OP_SELL) {
      if(true) useTrailingStop = true;
      if(useTrailingStop)
        updateTrailingStop("Short",magic.getOneR(OrderMagicNumber()));
    }
  }
}

void Robo::updateTrailingStop(string side,int oneR) {
  Debug("updateTrailingStop entered:  side="+side+"   oneR="+oneR);
  double newStopLoss = riskMgr.getTrailingStop(side,oneR);
  Debug("newStopLoss="+newStopLoss);
  if(newStopLoss > 0)
    broker.modifyStopLoss(OrderTicket(),newStopLoss);
}
/*
  double newStopLoss = riskMgr.calcStopLoss(side);
  double currStopLoss = OrderStopLoss();
  if(side == "Long") 
    if(newStopLoss-currStopLoss >= MinStopLossDeltaPips * BaseCcyTickValue) 
      broker.modifyStopLoss(newStopLoss);
  if(side == "Short")
    if(currStopLoss-newStopLoss >= MinStopLossDeltaPips * BaseCcyTickValue) 
      broker.modifyStopLoss(newStopLoss);
}
*/

void Robo::checkForSetups(void) {
}