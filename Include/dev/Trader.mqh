//+------------------------------------------------------------------+
//|                                                       Trader.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <dev\Position.mqh>
#include <dev\PositionSizer.mqh>
#include <dev\InitialRisk.mqh>
#include <dev\ExitManager.mqh>
#include <dev\ProfitTargetModels.mqh>
#include <dev\Setup.mqh>
#include <dev\MagicNumber.mqh>
#include <dev\PriceModels.mqh>
#include <dev\PriceModelsFake.mqh>

class Trader {
private:
  PositionSizer *sizer;
  MagicNumber *magic;
  PriceModelsBase *price;
  ExitManager *exitMgr;
  InitialRisk *initRisk;
  ProfitTargetModels *profitTgt;
public:
  Trader(ExitManager*,InitialRisk*,ProfitTargetModels*);
  ~Trader();
  
  Position *newTrade(Setup*);
  double calcStopLoss(Position *);
};

Trader::Trader(ExitManager* em,InitialRisk* ir, ProfitTargetModels *pt) {
  sizer = new PositionSizer();
  magic = new MagicNumber();
  if(Testing)
    price = new PriceModelsFake();
  else
    price = new PriceModels();
  profitTgt = pt;
  exitMgr = em;
  initRisk = ir;
}

Trader::~Trader() {
 if (CheckPointer(sizer)    == POINTER_DYNAMIC) delete sizer;
 if (CheckPointer(initRisk) == POINTER_DYNAMIC) delete initRisk;
 if (CheckPointer(magic)    == POINTER_DYNAMIC) delete magic;
 if (CheckPointer(price)    == POINTER_DYNAMIC) delete price;
 //if (CheckPointer(ptgt)     == POINTER_DYNAMIC) delete ptgt;
}
//+------------------------------------------------------------------+

Position *Trader::newTrade(Setup *setup) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  Debug(__FUNCTION__,__LINE__,"setup.side="+EnumToString(setup.side));

  Position *trade = new Position();
  if(setup.side == Long) {
    Debug(__FUNCTION__,__LINE__,"Long");
    trade.OrderType = OP_BUYSTOP;
    trade.SideX = 1;
  }
  if(setup.side == Short) {
    Debug(__FUNCTION__,__LINE__,"Short");
    trade.OrderType = OP_SELLSTOP;
    trade.SideX = -1;
  }
  trade.Symbol = setup.symbol;
  trade.Side = setup.side;

  int oneR = initRisk.getInPips(trade);
  double entryPrice = price.entryPrice(trade);

  trade.IsPending = true;
  trade.OpenPrice = entryPrice;

  if(exitMgr.useStopLoss) {
    trade.StopPrice = (setup.side==Long ? trade.OpenPrice - oneR*PipSize :
                                          trade.OpenPrice + oneR*PipSize);
  }
  
  trade.Symbol = setup.symbol;
  trade.OneRpips = oneR;
  trade.LotSize = sizer.lotSize(trade);
  trade.Reference = __FILE__;
  trade.Magic = magic.get(setup.strategyName,oneR);
  trade.TakeProfitPrice = profitTgt.getTargetPrice(trade,PT_Model);
  trade.RewardPips = int((trade.TakeProfitPrice-entryPrice)*trade.SideX*PipFact);
  
  return(trade);
};

double Trader::calcStopLoss(Position *pos) {
  double newStopLoss;
  double px = (pos.Side==Long?Bid:Ask);
  if(px-OrderOpenPrice()>exitMgr.pips2startTS(pos)*P2D)
    return(NULL);
  newStopLoss = exitMgr.getTrailingStop(pos);
  if(newStopLoss > 0) {
    pos.StopPrice = newStopLoss;
    return(newStopLoss);
  }
  return(NULL);
}
