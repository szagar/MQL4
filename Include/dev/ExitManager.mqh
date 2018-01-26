//+------------------------------------------------------------------+
//|                                                  ExitManager.mqh |
//+------------------------------------------------------------------+
#property strict

extern string commentString_7 = "";  //*****************************************
extern string commentString_8 = "";  //EXIT MANAGER SETTINGS
extern Enum_EXIT_MODELS EX_Model = EX_SL_TP;     //- Exit Model
extern Enum_YESNO       EX_TimedExit = YN_NO;    //- add Timed Exit ?
extern Enum_YESNO       EX_BarCount = YN_NO;     //- add Bar Count Exit ?
extern Enum_TS_TYPES    TS_Model = TS_ATR;       //- Trailing Stop Model
extern double           TS_MinDelta  = 2.0;      //   >> Min pips for SL change
extern int              TS_BarCount  = 3;        //   >> Bar Count or Bars back
extern int              TS_PadAmount = 10;       //   >> Pips to pad TS
extern Enum_TS_WHEN     TS_When      = TS_OneRx; //   >> When to start trailing
extern int              TS_WhenX     = 1;        //   >> When parameter (1Rx, pips)
extern ENUM_TIMEFRAMES  TS_ATRperiod= 0;         //   >> ATR Period
extern double           TS_ATRfactor = 2.7;      //   >> ATR Factor


class ExitManager {
private:
  string symbol;
  int d2p;                 // decimal to pips conversion factor
  //int EquityModel;
  int defaultModel;

  int oneR_calc_PATI();
  //double oneR_calc_ATR(int,int);
  double atr(int, int);

  double availableFunds();
  void configParams();

public:
  ExitManager();
  //ExitManager(const int=1, const int=1);
  ~ExitManager();

  double calcTrailingStopLoss(string,int);
  double getTrailingStop(Position *pos);
  bool useStopLoss;
  int pips2startTS(Position*);
};

ExitManager::ExitManager() {
  symbol = Symbol();

  d2p = PipFact;
  configParams();
}

ExitManager::~ExitManager() {
}

ExitManager::configParams() {
  switch(EX_Model) {
    case EX_Fitch:
      useStopLoss = false;
      break;
    case EX_SL_TP:
      useStopLoss = true;
      break;
  }
}

int ExitManager::pips2startTS(Position *pos) {
  int pips;
  switch(TS_When) {
    case TS_OneRx:
      pips = int(pos.OneRpips * TS_WhenX);
      break;
    case TS_PIPs:
      pips = TS_WhenX;
      break;
    default:
      pips = 0;
  }
  return (pips);
}

double ExitManager::getTrailingStop(Position *pos) {
  double currentPrice, newTrailingStop;
  double currStopLoss=OrderStopLoss();
  int pips=0;

  currentPrice = NormalizeDouble((pos.Side == Long ? Bid : Ask),Digits);
    
  switch(TS_Model) {
    case TS_CandleTrail:
      newTrailingStop = ((pos.Side==Long) ? iLow(NULL,0,TS_BarCount) :
                                            iHigh(NULL,0,TS_BarCount));
      break;
    case TS_ATR:
      pips = int(atr(TS_ATRperiod,TS_BarCount)*PipFact * TS_ATRfactor);
      newTrailingStop = currentPrice + pips * OnePoint * pos.Side;
      break;
    case TS_OneR:
      pips = pos.OneRpips;
      newTrailingStop = currentPrice + pips * OnePoint * pos.Side;
      break;
    default:
      newTrailingStop = currentPrice;;
  }
  newTrailingStop -= TS_PadAmount*pos.SideX;
  newTrailingStop = NormalizeDouble(newTrailingStop,Digits);

  double tmp = newTrailingStop-currStopLoss;
  if(currStopLoss==0 || (newTrailingStop-currStopLoss)*pos.Side >= TS_MinDelta * BaseCcyTickValue * OnePoint) {
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
