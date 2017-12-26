//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//+------------------------------------------------------------------+
#property strict

extern string _dummy1 = "=== RiskManager Params ===";
extern int RiskModel = 1;
extern Enum_TRAILING_STOP_TYPES TrailingStopModel = 2;
extern double Percent2risk = 0.5;
extern double MinStopLossDeltaPips = 2.0;
extern int TrailingStopBarShift = 1;
extern ENUM_TIMEFRAMES TS_ATRperiod = 0;
extern int TS_ATRnumBars = 3;
extern double TS_ATRfactor = 2.7;

#include <zts\account.mqh>
//#include <zts\pip_tools.mqh>

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
  //bool checkTrailingStopTrigger();

  double availableFunds();

public:
  RiskManager(const int=1, const int=1);
  ~RiskManager();

  //double oneRpips();
  double calcTrailingStopLoss(string,int);
  double getTrailingStop(Position *pos, Enum_TRAILING_STOP_TYPES _model=NA);

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

/*
double RiskManager::oneRpips() {
  double pips;

  switch (RiskModel) {
    case 1:
      pips = double(oneR_calc_PATI());
      break;
    case 2:
      pips = oneR_calc_ATR(TS_ATRperiod,TS_ATRnumBars);
      break;
    default:
      pips=0;
  }
  Debug4(__FUNCTION__,__LINE__,"model="+IntegerToString(RiskModel)+"  pips="+string(pips));
  return(pips);
}
*/

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

/*
double RiskManager::calcStopLoss(string side) {
  double stopLoss;
  double freeMargin = account.freeMargin();    //  AccountFreeMargin()
  double dollarRisk = (freeMargin + LockedInProfit()) * Percent2risk/100.0;
  double oneR = oneRpips() * BaseCcyTickValue;
  double lotSize = dollarRisk / oneR * Point;

   lotSize=MathRound(lotSize/MarketInfo(Symbol(),MODE_LOTSTEP)) * MarketInfo(Symbol(),MODE_LOTSTEP);
   
  return(stopLoss);
}
*/


/*
double RiskManager::calcTrailingStopLoss(string side, int oneR) {
  int signAdj = 1;
  double currentPrice = Ask;
  double newTrailingStop = 9999.99;
  double pips;
  //double stopLoss;
  
  Debug("Side="+side+"  oneR="+string(oneR)+"  Bid = "+string(Bid)+"   Ask="+string(Ask));
  if(StringCompare(side,"LONG",false)==0) {
    Debug("Long trade");
    currentPrice = Bid;
    signAdj = -1;
    newTrailingStop = 0.00;
  }
  
  switch (TrailingStopModel) {
    case 0:     // No trailing stop
      pips = 0.0;
      break;
    case 1:     // by oneR
      pips = oneR;
      break;
    case 2:     // current ATR
      pips = oneR_calc_ATR(ATRperiod,ATRnumBars)*decimal2points_factor(symbol)*2.0;
      Debug("trailing stop pips = "+string(pips));
      break;
    default:
      pips=0;
  }
  Info(__FUNCTION__+": model="+IntegerToString(TrailingStopModel)+"  pips="+string(pips));
  if(StringCompare(side,"LONG",false)==0) currentPrice = Bid;
  if(StringCompare(side,"SHORT",false)==0) currentPrice = Ask;
  Debug("newTrailingStop = currentPrice + pips * OnePoint * signAdj");
  Debug(string(newTrailingStop)+" = "+string(currentPrice)+" + "+string(pips)+" * "+string(OnePoint)+" * "+string(signAdj));
  newTrailingStop = currentPrice + pips * OnePoint * signAdj;
  Debug("newTrailingStop="+string(newTrailingStop));
    
  return(newTrailingStop); 
}
*/

double RiskManager::getTrailingStop(Position *pos, Enum_TRAILING_STOP_TYPES _model=NA) {
  Enum_TRAILING_STOP_TYPES model = (_model == NA ? TrailingStopModel : _model);
  double currentPrice, newTrailingStop;
  double currStopLoss=OrderStopLoss();
  int pips=0;

  currentPrice = NormalizeDouble((pos.Side == Long ? Bid : Ask),Digits);
    
  switch(model) {
    case PrevHL:
      newTrailingStop = ((pos.Side==Long) ? iLow(NULL,0,TrailingStopBarShift) : iHigh(NULL,0,TrailingStopBarShift));
      break;
    case ATR:
      pips = int(oneR_calc_ATR(TS_ATRperiod,TS_ATRnumBars)*decimal2points_factor(symbol)*TS_ATRfactor);
      newTrailingStop = currentPrice + pips * OnePoint * pos.Side;
      Debug4(__FUNCTION__,__LINE__,"side= "+EnumToString(pos.Side)+" = "+IntegerToString(pos.Side));
      Debug4(__FUNCTION__,__LINE__,EnumToString(model)+": "+DoubleToStr(newTrailingStop,Digits)+" = "+DoubleToStr(currentPrice,2)+" + "+IntegerToString(pips)+" * "+string(OnePoint)+" * "+EnumToString(pos.Side)+";");
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
  Debug4(__FUNCTION__,__LINE__,DoubleToStr(currStopLoss,Digits)+"==0 || ("+DoubleToStr(tmp,Digits)+")*"+EnumToString(pos.Side)+" >= "+DoubleToStr(MinStopLossDeltaPips * BaseCcyTickValue * OnePoint,Digits)+")");
  if(currStopLoss==0 || (newTrailingStop-currStopLoss)*pos.Side >= MinStopLossDeltaPips * BaseCcyTickValue * OnePoint) {
    Debug4(__FUNCTION__,+__LINE__,"model="+IntegerToString(RiskModel)+"  pips="+string(pips)+"  "+DoubleToStr(currStopLoss,2)+"->"+DoubleToStr(newTrailingStop,Digits));
    return(newTrailingStop);
  }
  return(-1);
}

/*
bool RiskManager::checkTrailingStopTrigger() {
  // profit trigger
  d2p = decimal2points_factor(symbol);
  //if(OrderType()==OP_BUY){
  //  _buyspips+=(OrderClosePrice()-OrderOpenPrice()) * d2p;
  //}
  //if(OrderType()==OP_SELL){
  //  _sellspips+=(OrderOpenPrice()-OrderClosePrice()) * d2p;
  //}

  
  // time trigget
  //if(nowLocal >= TS_time_trigger)
  //  useTrailingStop = true;

    return(true);
  }
*/