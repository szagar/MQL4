//+------------------------------------------------------------------+
//|                                                  ExitManager.mqh |
//+------------------------------------------------------------------+
#property strict

extern string commentString_7 = "*****************************************";
extern string commentString_8 = "EXIT MANAGER SETTINGS";
extern Enum_EXITMODEL ExitModel = 1;
extern Enum_TRAILING_STOP_TYPES TrailingStopModel = TS_ATR;
extern double MinStopLossDeltaPips = 2.0;
extern int TS_BarCount = 3;
extern ENUM_TIMEFRAMES TS_ATRperiod = 0;
extern double TS_ATRfactor = 2.7;
extern string commentString_9 = "*****************************************";

#include <zts\account.mqh>

class ExitManager {
private:
  string symbol;
  int d2p;                 // decimal to pips conversion factor
  //int EquityModel;
  int defaultModel;
  Enum_EXITMODEL exitModel;
  Account *account;

  int oneR_calc_PATI();
  //double oneR_calc_ATR(int,int);
  double atr(int, int);

  double availableFunds();
  void configParams();

public:
  //ExitManager();
  ExitManager(const Enum_EXITMODEL _exitModel);
  //ExitManager(const int=1, const int=1);
  ~ExitManager();

  double calcTrailingStopLoss(string,int);
  double getTrailingStop(Position *pos, Enum_TRAILING_STOP_TYPES _model=TS_None);
  bool useStopLoss;
};

//ExitManager::ExitManager(const int _equityModel=1, const Enum_EXITMODEL _exitModel=1) {
ExitManager::ExitManager(const Enum_EXITMODEL _exitModel) {
  symbol = Symbol();
  //EquityModel = _equityModel;
  exitModel = _exitModel;

  account = new Account();
  d2p = decimal2points_factor(symbol);
  configParams();
}

ExitManager::~ExitManager() {
  if (CheckPointer(account) == POINTER_DYNAMIC) delete account;
}

ExitManager::configParams() {
  switch(exitModel) {
    case EX_Fitch:
      useStopLoss = false;
      break;
    case EX_SL_TP:
      useStopLoss = true;
      break;
  }
}

//double ExitManager::availableFunds() {
//  double dollars;
//
//  switch(EquityModel){
//    case 1:
//      dollars = account.freeMargin();
//      break;
//    default:
//      dollars = 0.0;
//  }
//  return(dollars);
//}

/**
int ExitManager::oneR_calc_PATI() {
  int __defaultStopPips = 12;
  string __exceptionPairs = "EURUSD/8;AUDUSD,GBPUSD,EURJPY,USDJPY,USDCAD/10";
  
  int stop = __defaultStopPips;
  int pairPosition = StringFind(__exceptionPairs, symbol, 0);
  if (pairPosition >=0) {
     int slashPosition = StringFind(__exceptionPairs, "/", pairPosition) + 1;
     stop =int( StringToInteger(StringSubstr(__exceptionPairs,slashPosition)));
  }
  Debug4(__FUNCTION__,__LINE__,"pips="+IntegerToString(stop));
  return stop;
}

double ExitManager::oneR_calc_ATR(int _period, int _numBars) {
  double atr = iATR(symbol,     // symbol
                    _period,     // timeframe
                    _numBars,    // averaging period
                    0);          // shift
  atr = NormalizeDouble(atr, int(MarketInfo(symbol, MODE_DIGITS)-1));
  Debug4(__FUNCTION__,__LINE__,"atr "+string(_numBars)+" bars. period = "+string(_period)+"  atr="+string(atr));
  return(atr);
}
*/


double ExitManager::getTrailingStop(Position *pos, Enum_TRAILING_STOP_TYPES _model=TS_None) {
  Enum_TRAILING_STOP_TYPES model = (_model == TS_None ? TrailingStopModel : _model);
  double currentPrice, newTrailingStop;
  double currStopLoss=OrderStopLoss();
  int pips=0;

  currentPrice = NormalizeDouble((pos.Side == Long ? Bid : Ask),Digits);
    
  switch(model) {
    case TS_PrevHL:
      newTrailingStop = ((pos.Side==Long) ? iLow(NULL,0,TS_BarCount) :
                                            iHigh(NULL,0,TS_BarCount));
      break;
    case TS_ATR:
      pips = int(atr(TS_ATRperiod,TS_BarCount)*decimal2points_factor(symbol) * TS_ATRfactor);
      newTrailingStop = currentPrice + pips * OnePoint * pos.Side;
      break;
    case TS_OneR:
      pips = pos.OneRpips;
      newTrailingStop = currentPrice + pips * OnePoint * pos.Side;
      break;
    default:
      newTrailingStop = currentPrice;;
  }
  newTrailingStop = NormalizeDouble(newTrailingStop,Digits);

  double tmp = newTrailingStop-currStopLoss;
  if(currStopLoss==0 || (newTrailingStop-currStopLoss)*pos.Side >= MinStopLossDeltaPips * BaseCcyTickValue * OnePoint) {
    return(newTrailingStop);
  }
  return(-1);
}

double ExitManager::atr(int _period, int _numBars) {
  double atr = iATR(symbol,     // symbol
                    _period,     // timeframe
                    _numBars,    // averaging period
                    0);          // shift
  atr = NormalizeDouble(atr, int(MarketInfo(symbol, MODE_DIGITS)-1));
  return(atr);
}
