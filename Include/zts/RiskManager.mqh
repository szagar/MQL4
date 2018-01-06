//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//+------------------------------------------------------------------+
#property strict

enum Enum_RISKMODEL {R_PATI, R_ATR};

extern string _dummy1 = "=== RiskManager Params ===";
extern Enum_RISKMODEL RiskModel = 1;
extern Enum_TRAILING_STOP_TYPES TrailingStopModel = 2;
extern double Percent2risk = 0.5;
extern double MinStopLossDeltaPips = 2.0;
extern int TrailingStopBarShift = 1;
extern ENUM_TIMEFRAMES TS_ATRperiod = 0;
extern int TS_ATRnumBars = 3;
extern double TS_ATRfactor = 2.7;

#include <zts\account.mqh>

class RiskManager {
private:
  string symbol;
  int d2p;                 // decimal to pips conversion factor
  int EquityModel;
  int defaultModel;
  int RiskModel;
  Account *account;

  int oneR_calc_PATI();
  double oneR_calc_ATR(int,int);

  double availableFunds();

public:
  RiskManager(const int=1, const int=1);
  ~RiskManager();

  double calcTrailingStopLoss(string,int);
  double getTrailingStop(Position *pos, Enum_TRAILING_STOP_TYPES _model=None);

};

RiskManager::RiskManager(const int _equityModel=1, const int _riskModel=1) {
  symbol = Symbol();
  EquityModel = _equityModel;
  RiskModel = _riskModel;
  account = new Account();
  d2p = decimal2points_factor(symbol);
}

RiskManager::~RiskManager() {
  if (CheckPointer(account) == POINTER_DYNAMIC) delete account;
}

double RiskManager::availableFunds() {
  double dollars;

  switch(EquityModel){
    case 1:
      dollars = account.freeMargin();
      break;
    default:
      dollars = 0.0;
  }
  return(dollars);
}

int RiskManager::oneR_calc_PATI() {
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

double RiskManager::oneR_calc_ATR(int _period, int _numBars) {
  double atr = iATR(symbol,     // symbol
                    _period,     // timeframe
                    _numBars,    // averaging period
                    0);          // shift
  atr = NormalizeDouble(atr, int(MarketInfo(symbol, MODE_DIGITS)-1));
  Debug4(__FUNCTION__,__LINE__,"atr "+string(_numBars)+" bars. period = "+string(_period)+"  atr="+string(atr));
  return(atr);
}



double RiskManager::getTrailingStop(Position *pos, Enum_TRAILING_STOP_TYPES _model=None) {
  Enum_TRAILING_STOP_TYPES model = (_model == None ? TrailingStopModel : _model);
  double currentPrice, newTrailingStop;
  double currStopLoss=OrderStopLoss();
  int pips=0;

  currentPrice = NormalizeDouble((pos.Side == Long ? Bid : Ask),Digits);
    
  switch(model) {
    case PrevHL:
      newTrailingStop = ((pos.Side==Long) ? iLow(NULL,0,TrailingStopBarShift) :
                                            iHigh(NULL,0,TrailingStopBarShift));
      break;
    case ATR:
      pips = oneR_calc_ATR(TS_ATRperiod,TS_ATRnumBars)*decimal2points_factor(symbol);
      pips *= TS_ATRfactor;
      newTrailingStop = currentPrice + pips * OnePoint * pos.Side;
      break;
    case OneR:
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

