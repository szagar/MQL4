//+------------------------------------------------------------------+
//|                                                   ExitTrader.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\MagicNumber.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//|       Exit Model:
//|         Partial Profit Model:                                                          ExitPartialProfit=0
//|               0 : use default
//|               1 : full exit
//|               2 : 1st profitable target is 1/2 position
//|         Time Exit Model:                                                               TimeExitModel=0
//|               when: for each new bar
//|               0 : use default
//|               1 : no time exit
//|               2 : at number of bars after entry (N bars)                               TimeExitBars
//|               3 : at hh:mm (exit time)                                                 TimeExitTime
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

extern string ExitTraderParams = "======== Exit Trader =======";
extern string ExitTraderParams1 = "======== -- Partial Profit =======";
extern int ExitModel = 1;
extern int ExitPartialProfit = 0;
extern string ExitTraderParams2 = "======== -- Time Exit =======";
extern int TimeExitModel = 0;
extern int TimeExitBars = 10;
extern datetime TimeExitTime = NULL;
extern string ExitTraderParams3 = "======== -- Trailing Stop =======";
extern Enum_TRAILING_STOP_TYPES TS_Model = 1;
extern int TSbarsBack = 1;
extern int TSatrX10 = 27;
extern ENUM_TIMEFRAMES TSatrTimeFrame = PERIOD_D1;
extern int TSatrPeriods = 14;
extern ENUM_MA_METHOD TSmaType = MODE_SMA;
extern ENUM_TIMEFRAMES TSmaTimeFrame = 0;
extern int TSmaBufferPips = 1;
extern string ExitTraderParams4 = "======== -- Profit Target =======";
extern int ExitProfitTargetModel = 0;

class ExitTrader {
private:
  int _exitPartialProfit;
  int _timeExitModel;
  int _timeExitBars;
  datetime _timeExitTime;
  int _trailingStopModel;
  int _tSbarsBack;
  int _tSatrX10;
  ENUM_TIMEFRAMES _tSatrTimeFrame;
  int _tSatrPeriods;
  ENUM_TIMEFRAMES _tSmaTimeFrame;
  int _tSmaBufferPips;
  ENUM_MA_METHOD _tSmaType;
  int _tSpips;
  int _exitProfitTargetModel;
  MagicNumber *magic;

  void setParams();
  void exitModelParams(int model);
  void timeExitModelParams(int model);
  void trailingStopParams(int model);

public:
  ExitTrader();
  ~ExitTrader();
  
  bool handleTimeExit();
  void handlePartialProfit();
  void updateTrailingStop();
  double getTrailingStop(Position *pos, Enum_TRAILING_STOP_TYPES _model=None);
};

ExitTrader::ExitTrader() {
  magic = new MagicNumber();
}

ExitTrader::~ExitTrader() {
}

bool ExitTrader::handleTimeExit() {
  return false;
}

void ExitTrader::handlePartialProfit() {
}

void ExitTrader::updateTrailingStop() {
}

void ExitTrader::setParams() {
  exitModelParams(ExitModel);
  timeExitModelParams(_timeExitModel);
  trailingStopParams(_trailingStopModel);

  /*
  _exitPartialProfit = 0;
  _timeExitModel = 0;
  _timeExitBars = 10;
  _timeExitTime = NULL;
  _trailingStopModel = 0;
  _tSbarsBack = 1;
  _tSatrX10 = 27;
  _tSatrTimeFrame = PERIOD_D1;
  _tSatrPeriods = 14;
  _exitProfitTargetModel = 0;
  */
}

void ExitTrader::exitModelParams(int model) {
  switch(model) {
    case 0:
      _timeExitModel = 0;
      _trailingStopModel = 0;
      _exitProfitTargetModel = 2;   // next PATI level
      break;
    case 1:
      _timeExitModel = 0;
      _trailingStopModel = 1;
      _exitProfitTargetModel = 0;
      break;
    case 2:
      _timeExitModel = 0;
      _trailingStopModel = 1;
      _exitProfitTargetModel = 2;
      break;
  }
  if(TimeExitModel > 0) _timeExitModel = TimeExitModel;
  if(TS_Model > 0) _trailingStopModel = TS_Model;
  if(ExitProfitTargetModel > 0) _exitProfitTargetModel = ExitProfitTargetModel;
}

void ExitTrader::timeExitModelParams(int model) {
  if(model == 0) model = 1;
  switch(model) {
    case 1:  // no time exit
      _timeExitBars = 0;
      _timeExitTime = NULL;
      break;
    case 2:  // exit n bars after entry
      _timeExitBars = TimeExitBars;
      _timeExitTime = NULL;
      break;
    case 3:  // exit at hh:mm
      _timeExitBars = 0;
      _timeExitTime = TimeExitTime;
      break;
  }
  if(TimeExitBars > 0) _timeExitBars = TimeExitBars;
  if(TimeExitTime) _timeExitTime = TimeExitTime;
}

void ExitTrader::trailingStopParams(int model) {
  if(model == 0) model = 1;
  switch(model) {
    case 1:    // no trailing stop
      _tSatrX10 = 0;
      _tSatrTimeFrame = 0;
      _tSatrPeriods = 0;
      break;
    case 2:    // trail at previous bar H/L
      _tSbarsBack = 1;
      break;
    case 3:    // trail at N * ATR(timeframe,num periods)
      _tSatrX10 = 27;
      _tSatrTimeFrame = 0;
      _tSatrPeriods = 14;
      break;
    case 4:    // trail at 1R
      Debug4(__FUNCTION__,__LINE__,"call magic.getOneR("+OrderMagicNumber()+");");
      _tSpips = magic.getOneR(OrderMagicNumber());
         Info(__FUNCTION__+": _tSpips="+string(_tSpips));
      break;
    case 5:    // trail with moving average
      _tSmaType = MODE_SMA;
      _tSmaTimeFrame = 0;
      _tSmaBufferPips = 2;
      break;
  }
  if(TSatrX10 > 0) _tSatrX10 = TSatrX10;
  if(TSatrTimeFrame > 0) _tSatrTimeFrame = TSatrTimeFrame;
  if(TSatrPeriods > 0) _tSatrPeriods = TSatrPeriods;
  if(_tSbarsBack > 0) _tSbarsBack = TSbarsBack;
  if(_tSmaType == MODE_SMA || _tSmaType == MODE_EMA) _tSmaType = TSmaType;
  if(_tSmaTimeFrame > 0) _tSmaTimeFrame = TSmaTimeFrame;
  if(_tSmaBufferPips > -1) _tSmaBufferPips = TSmaBufferPips;
}

double ExitTrader::getTrailingStop(Position *pos, Enum_TRAILING_STOP_TYPES _model=None) {
  Enum_TRAILING_STOP_TYPES model = (_model == None ? TS_Model : _model);
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
  if(currStopLoss==0 || (newTrailingStop-currStopLoss)*pos.Side >= MinStopLossDeltaPips * BaseCc
yTickValue * OnePoint) {
    return(newTrailingStop);
  }
  return(-1);
}
