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
#include <dev\EntryModels.mqh>
#include <dev\PriceModels.mqh>
#include <dev\PriceModelsFake.mqh>

class Trader {
private:
  PositionSizer *sizer;
  MagicNumber *magic;
  EntryModels *entry;
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
  entry = new EntryModels();
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
 if (CheckPointer(entry)    == POINTER_DYNAMIC) delete entry;
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
  trade.LotSize = sizer.lotSize(1);
  trade.Symbol = setup.symbol;
  //trade.Side = (trade.LotSize >= 0 ? Long : Short);
  trade.Side = setup.side;

  int oneR = initRisk.getInPips(trade);
  Debug(__FUNCTION__,__LINE__,"oneR="+IntegerToString(oneR));
  double entryPrice = (setup.side==Long ? entry.entryPriceLong() : entry.entryPriceShort());

  trade.IsPending = true;
  trade.OpenPrice = entryPrice;
  price.entryPrice(trade);
  Debug(__FUNCTION__,__LINE__,"trade.OpenPrice="+DoubleToStr(trade.OpenPrice,Digits));

  if(exitMgr.useStopLoss) {
    double stopLoss =  (setup.side==Long ? trade.OpenPrice - oneR*points2decimal_factor(setup.symbol) : trade.OpenPrice + oneR*points2decimal_factor(setup.symbol));
    trade.StopPrice = stopLoss;
    Debug(__FUNCTION__,__LINE__,"trade.StopPrice="+DoubleToStr(trade.StopPrice,Digits));
  }
  
  trade.Symbol = setup.symbol;
  trade.OneRpips = oneR;
  trade.Reference = __FILE__;
  trade.Magic = magic.get(setup.strategyName,oneR);
  trade.TakeProfitPrice = profitTgt.getTargetPrice(trade,PT_Model);
  trade.RewardPips = int((trade.TakeProfitPrice-entryPrice)*trade.SideX*decimal2points_factor(setup.symbol));
  
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
