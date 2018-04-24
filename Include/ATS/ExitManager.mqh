//+------------------------------------------------------------------+
//|                                                  ExitManager.mqh |
//+------------------------------------------------------------------+
#property strict

#include <ATS\zts_lib.mqh>
#include <ATS\exit_externs.mqh>


class ExitManager {
private:
  string symbol;
  int d2p;                 // decimal to pips conversion factor
  //int EquityModel;
  int defaultModel;

  int oneR_calc_PATI();
  //double oneR_calc_ATR(int,int);
  //double atr(int, int);

  double availableFunds();
  //void configParams();

public:
  ExitManager();
  //ExitManager(const int=1, const int=1);
  ~ExitManager();

  void updateTrailingStops(string strategyName);
  double calcTrailingStopLoss(string,int);
  double getTrailingStop(Position *pos);
  //bool useTakeProfit;
  int pips2startTS(Position*);
};

ExitManager::ExitManager() {
  symbol = Symbol();

  d2p = PipFact;
  //configParams();
}

ExitManager::~ExitManager() {
}

//ExitManager::configParams() {
//  switch(EX_Model) {
//    case EX_Fitch:
//      //useStopLoss = false;
//      //useTrailingStop = false;
//      break;
//    case EX_SL_TP:
//      UseTakeProfit = true;
//      break;
//    case EX_SL_TS:
//      UseTakeProfit = true;
//      break;
//  }
//}

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
  int pips,val_index;
  double delta;

  currentPrice = NormalizeDouble((pos.Side == Long ? Bid : Ask),Digits);
  currentPrice = Close[1];
   
  switch(TS_Model) {
    case TS_PATI_PIPS:
      pips = calcPatiPips(pos.Symbol);
      newTrailingStop = currentPrice - pips * P2D * pos.SideX;
      break;
    case TS_CandleTrail:
      newTrailingStop = ((pos.Side==Long) ? iLow(NULL,0,TS_BarCount) :
                                            iHigh(NULL,0,TS_BarCount));
      break;
    case TS_ATR:
      delta = (int)calc_ATR(pos.Symbol,TS_ATRperiod,TS_BarCount) * TS_ATRfactor;
      newTrailingStop = currentPrice - delta * pos.SideX;
      break;
    case TS_OneR:
      newTrailingStop = currentPrice + pos.OneRpips * P2D * pos.SideX;
      break;
    case TS_PrevHL:
      if(pos.Side==Long) {
        val_index=iHighest(NULL,0,MODE_HIGH,TS_BarCount+1,1);
        newTrailingStop=iHigh(NULL,0,val_index);
      } else {
        val_index=iLowest(NULL,0,MODE_LOW,TS_BarCount+1,1);
        newTrailingStop=iLow(NULL,0,val_index);
      }
      break;
    default:
      return(-1);
  }
  newTrailingStop -= TS_PadAmount*PipSize*pos.SideX;
  newTrailingStop = NormalizeDouble(newTrailingStop,Digits);

  LogTrade(__FUNCTION__,__LINE__,(string)pos.TicketId+" currentStopLoss="+DoubleToStr(currStopLoss,Digits)+"  newTrailingStop="+DoubleToStr(newTrailingStop,Digits)+"  OrderStopLoss="+DoubleToStr(pos.StopPrice,Digits));
  if(currStopLoss==0 ||
     (newTrailingStop-currStopLoss)*pos.SideX*D2P >= TS_MinDeltaPips) {
    LogTrade(__FUNCTION__,__LINE__,"return("+DoubleToStr(newTrailingStop,Digits)+")");
    return(newTrailingStop);
  }
  return(-1);
}

void ExitManager::updateTrailingStops(string strategyName) {
  if(OrdersTotal()==0) return;
  for(int i=OrdersTotal()-1; i>=0; i--) {
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true) {
      if(!magic.matchStrategyName(strategyName)) continue;

    }
  }
}
