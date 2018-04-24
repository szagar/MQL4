//+------------------------------------------------------------------+
//|                                                  ExitManager.mqh |
//+------------------------------------------------------------------+
#property strict

extern string commentString_EM_1 = ""; //---------------------------------------------
extern string commentString_EM_2 = ""; //-------- Exit Manager settings
extern string commentString_EM_3 = ""; //---------------------------------------------
extern Enum_EXIT_MODELS EX_Model = EX_EOS;       //>> Exit Model
extern Enum_TS_TYPES    TS_Model = TS_ATR;       //>> Trailing Stop Model
//extern bool             EX_TimedExit = YN_NO;    //-   use Timed Exit ?
extern bool             EX_BarCount = YN_NO;     //-   add Bar Count Exit ?
extern double           TS_MinDeltaPips  = 2.0;  //-   TS: Min pips for SL change
extern int              TS_BarCount  = 3;        //-   TS: Bar Count or Bars back
extern int              TS_PadAmount = 10;       //-   TS: Pips to pad TS
extern Enum_TS_WHEN     TS_When      = TS_OneRx; //-   TS: When to start trailing
extern int              TS_WhenX     = 1;        //-   TS: When parameter (1Rx, pips)
extern ENUM_TIMEFRAMES  TS_ATRperiod= 0;         //-   TS: ATR Period
extern double           TS_ATRfactor = 2.7;      //-   TS: ATR Factor


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
  //bool useTakeProfit;
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
      //useStopLoss = false;
      //useTrailingStop = false;
      break;
    case EX_SL_TP:
      UseTakeProfit = true;
      break;
    case EX_SL_TS:
      UseTakeProfit = true;
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
  Debug(__FUNCTION__,__LINE__,"Entered");
  double currentPrice, newTrailingStop;
  double currStopLoss=OrderStopLoss();
  int pips=0;

  currentPrice = NormalizeDouble((pos.Side == Long ? Bid : Ask),Digits);
   
  Debug(__FUNCTION__,__LINE__,"model="+EnumToString(TS_Model)+"  price="+DoubleToStr(currentPrice,Digits)+" currSL="+DoubleToStr(currStopLoss,Digits));
  switch(TS_Model) {
    case TS_CandleTrail:
      newTrailingStop = ((pos.Side==Long) ? iLow(NULL,0,TS_BarCount) :
                                            iHigh(NULL,0,TS_BarCount));
      break;
    case TS_ATR:
      Info("pips = int(atr(TS_ATRperiod,TS_BarCount)*PipFact * TS_ATRfactor);");
      Info("pips = int("+DoubleToStr(atr(TS_ATRperiod,TS_BarCount),Digits)+"*"+string(PipFact)+" * "+DoubleToStr(TS_ATRfactor,2)+")");
      pips = int(atr(TS_ATRperiod,TS_BarCount)*PipFact * TS_ATRfactor);
      Debug(__FUNCTION__,__LINE__,"pips="+string(pips));
      Info("newTrailingStop = "+DoubleToStr(currentPrice,Digits)+" + "+string(pips)+" * "+string(OnePoint)+" * "+EnumToString(pos.Side));
      newTrailingStop = currentPrice - pips * OnePoint * pos.Side;
      Debug(__FUNCTION__,__LINE__,"newTrailingStop="+string(newTrailingStop));
      break;
    case TS_OneR:
      pips = pos.OneRpips;
      newTrailingStop = currentPrice + pips * OnePoint * pos.Side;
      break;
    default:
      newTrailingStop = currentPrice;;
  }
  newTrailingStop -= TS_PadAmount*PipSize*pos.SideX;
      Debug(__FUNCTION__,__LINE__,"newTrailingStop="+string(newTrailingStop));
  newTrailingStop = NormalizeDouble(newTrailingStop,Digits);
      Debug(__FUNCTION__,__LINE__,"newTrailingStop="+string(newTrailingStop));

  Debug(__FUNCTION__,__LINE__,"(newTrailingStop-currStopLoss)= "+DoubleToStr((newTrailingStop-currStopLoss),Digits));
  Debug(__FUNCTION__,__LINE__,"pos.Side= "+EnumToString(pos.Side));
  Debug(__FUNCTION__,__LINE__,"PipFact= "+DoubleToStr(PipFact,Digits));
  Debug(__FUNCTION__,__LINE__,"TS_MinDeltaPips="+DoubleToStr(TS_MinDeltaPips,2));
  if(currStopLoss==0 || (newTrailingStop-currStopLoss)*pos.Side*PipFact >= TS_MinDeltaPips) {
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
