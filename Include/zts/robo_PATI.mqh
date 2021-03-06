#include <zts\oneR.mqh>
#include <zts\TradeSetup.mqh> 
#include <zts\TradeManager.mqh> 

class PatiParameters {
public:
  int DefaultStopPips;
  string StopPips;

  PatiParameters() {  
    DefaultStopPips = 12;
    StopPips = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
  }
};

class DevBase {
private:
  string TypeName;
  int DefaultStopPips;
  string StopPips;
  PatiParameters *params;
  bool BuySignal();
  bool trailingStop;
  double SetInitialR();
  string symbol;
  TradeSetup *setup;
  TradeManager *tradeMgr;
  
public:
  string ClassName;
  string Version;
  string Title;
  double oneRpips;

  DevBase(string, string name = "DevBase class");
  ~DevBase();

  void OnInit();
  void OnDeinit(const int reason);
  void OnTick();
  void OnNewBar();
  void OnChartEvent(const int id, const long& lParam, const double& dParam, const string& sParam);

  void CheckForSetup();
  //int InitialStopInPips();
  void UpdateTrigger();
  void ManageTrade();
  void ManageTrailingStop();
  string tradeStatsHeader();
  string tradeStats();
  void Buy();
  void SetStopAndProfitLevels(Position *trade, bool wasPending);
};

DevBase::DevBase(string _symbol, string _name = "DevBase class") {
   TypeName = "Mock class";
   ClassName = _name;
   Version = "0.002";
   Title = "ZTS Robo Framework dev";
   symbol = _symbol;
   params = new PatiParameters();
   trailingStop = false;
   setup = new TradeSetup();
  }

DevBase::~DevBase() {
  if (CheckPointer(params) == POINTER_DYNAMIC) delete params;
}
  
void DevBase::OnInit() {
  Print(__FUNCTION__,":  Entry");
  tradeMgr = new TradeManager();
}
 
void DevBase::OnDeinit(const int reason) {
  Print(__FUNCTION__,":  Entry");
  if (CheckPointer(tradeMgr) == POINTER_DYNAMIC) delete tradeMgr;
}

void DevBase::OnTick() {
  //Print(__FUNCTION__,":  Entry");
}

void DevBase::OnNewBar() {
  Print(__FUNCTION__,":  Entry");
  if(activeTrade) 
    tradeMgr.OnNewBar();
        // trailing stops
        // up 1/2R, start trailing
        // profit targets, scaling out of trades
    //ManageTrade();
  else if(!setup)
    CheckForSetup();
        //  20 pips after missed RBO
  else
    UpdateTrigger();
 }

/**
void DevBase::ManageTrade() {
  if(trailingStop) {
    ManageTrailingStop();
  }
}
**/


void DevBase::CheckForSetup() {
//  if(setup.type=="Range") {
//    if((iHigh(NULL,0,0) - setup.upperLevel) > 20) 
//      setup.InitiateCDM("Long");
//    if((setup.lowerLevel - iLow(NULL,0,0)) > 20) 
//      setup.InitiateCDM("Short");
//  }
}

void DevBase::UpdateTrigger() {
//  if(setup.type=="CDM") {
//    if(setup.side=="Long") {
//      if(iLow(NULL,0,1) > trade.LimitLevel)
//        broker.CancelEntryBuyLimit(iLow(NULL,9,1);
//    } else if(setup.side=="Short") {
//      if(iHigh(NULL,0,1) < trade.LimitLevel)
//        broker.CancelEntrySellLimit(iHigh(NULL,9,1);
//    }
//  }
} 

void DevBase::Buy() {
  Print(__FUNCTION__,": buy code here");
  double margin = 1.0;
  double price = Ask + (margin * OnePoint);
  //if(allowForSpread)  price += spread * Point;

  Position *trade = new Position();
  trade.IsPending = false;
  trade.OpenPrice = price;
  trade.OrderType = OP_BUY;                // OP_BUYSTOP;
  trade.Symbol = broker.NormalizeSymbol(symbol);
  trade.LotSize = CalcTradeSize(account,stopLoss,PercentRiskPerPosition);
  if(trade.LotSize == 0 && DEBUG_ORDER) {
    Print("Configured LotSize = 0 and no historical order found.  LotSize is 0");
  }
  if(DEBUG_ORDER) {
    Print("About to place pending order: Symbol=" +trade.Symbol + " Price = " + DoubleToStr(trade.OpenPrice));
  }
  SetStopAndProfitLevels(trade,false);
  broker.CreateOrder(trade);
  delete(trade);
  SetTradeTypeObj("Robo_01");
}

double DevBase::SetInitialR() {
  double pips = LookupStopPips(symbol);
  return(pips);
}

void DevBase::ManageTrailingStop() {
}

void DevBase::SetStopAndProfitLevels(Position *trade, bool wasPending) {
  //if(trade.OrderType == OP_BUY || trade.OrderType == OP_BUYLIMIT || trade.OrderType == OP_BUYSTOP))
  if((trade.OrderType & 0x0001) == 0) {  // All BUY order types are even
    if (trade.StopPrice == 0 || (wasPending && _adjustStopOnTriggeredPendingOrders)) 
      trade.StopPrice = trade.OpenPrice - oneRpips * OnePoint;
    if (_useNextLevelTPRule)
      if (trade.TakeProfitPrice == 0 || (wasPending && _adjustStopOnTriggeredPendingOrders)) 
        trade.TakeProfitPrice = GetNextLevel(trade.OpenPrice + _minRewardRatio*stopLoss, 1);
  }
  else { //SELL type
    if (trade.StopPrice ==0 ||(wasPending && _adjustStopOnTriggeredPendingOrders ) )
      trade.StopPrice = trade.OpenPrice + stopLoss;

    if (_useNextLevelTPRule)
      if (trade.TakeProfitPrice == 0 || (wasPending && _adjustStopOnTriggeredPendingOrders)) trade.TakeProfitPrice = GetNextLevel(trade.OpenPrice-_minRewardRatio*stopLoss, -1);
  }
  if (_sendSLandTPToBroker && !_testing) {
  Print("************************************************");
  Print("************************************************");
  Print("************************************************");
  Print("************************************************");
  Print("************************************************");
    Print("Sending to broker: TradeType=" + IntegerToString(trade.OrderType) + 
          " OpenPrice=" + DoubleToString(trade.OpenPrice,Digits) + 
          " StopPrice=" + DoubleToString(trade.StopPrice, Digits) +
          " TakeProfit=" + DoubleToString(trade.TakeProfitPrice, Digits)
          );
    broker.SetSLandTP(trade);
  }    
}

void DevBase::OnChartEvent(const int id, const long& lParam, const double& dParam, const string& sParam) {
  Print(__FUNCTION__,":  Entry");
}

/*
int DevBase::InitialStopInPips() {
  Print(__FUNCTION__,":  Entry");
  int stop = _defaultStopPips;
  int pairPosition = StringFind(_exceptionPairs, symbol, 0);
  if (pairPosition >=0) {
    int slashPosition = StringFind(_exceptionPairs, "/", pairPosition) + 1;
    stop = int(StringToInteger(StringSubstr(_exceptionPairs,slashPosition)));
  }
  return stop;
}
*/

string DevBase::tradeStatsHeader() {
  return("TBD1,TBD2");
}

string DevBase::tradeStats() {
  return("tbd1,tbd2");
}

bool DevBase::BuySignal() {
  int    Period_MA_1=11;      // Period of MA 1
  int    Period_MA_2=31;      // Period of MA 2

  double MA_1_t=iMA(NULL,0,Period_MA_1,0,MODE_LWMA,PRICE_TYPICAL,0); // МА_1
  double MA_2_t=iMA(NULL,0,Period_MA_2,0,MODE_LWMA,PRICE_TYPICAL,0); // МА_2
  return(MA_1_t > MA_2_t + 28*Point);
}
/****************************************************************************************/
/****************************************************************************************/


