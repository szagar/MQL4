//+------------------------------------------------------------------+
//|                                                       Trader.mqh |
//|                                                    Stephen Zagar |
//|                                                 https://www..com |
//+------------------------------------------------------------------+
#property copyright "Stephen Zagar"
#property link      "https://www..com"
#property version   "1.00"
#property strict

#include <zts\Position.mqh>
#include <zts\PositionSizer.mqh>
#include <zts\InitialRisk.mqh>
#include <zts\ExitManager.mqh>
#include <zts\Setup.mqh>
#include <zts\MagicNumber.mqh>
#include <zts\EntryModels.mqh>
#include <zts\ProfitTargetModels.mqh>

class Trader {
private:
  PositionSizer *sizer;
  MagicNumber *magic;
  EntryModels *entry;
  ProfitTargetModels *ptgt;
  ExitManager *exitMgr;
  InitialRisk *initRisk;
public:
  Trader(ExitManager*,InitialRisk*);
  ~Trader();
  
  Position *newTrade(Setup*);
  double calcStopLoss(Position *);
};

Trader::Trader(ExitManager* em,InitialRisk* ir) {
  sizer = new PositionSizer();
  magic = new MagicNumber();
  entry = new EntryModels(1);
  ptgt = new ProfitTargetModels();
  exitMgr = em;
  initRisk = ir;
}

Trader::~Trader() {
 if (CheckPointer(sizer)    == POINTER_DYNAMIC) delete sizer;
 if (CheckPointer(initRisk) == POINTER_DYNAMIC) delete initRisk;
 if (CheckPointer(magic)    == POINTER_DYNAMIC) delete magic;
 if (CheckPointer(entry)    == POINTER_DYNAMIC) delete entry;
 if (CheckPointer(ptgt)     == POINTER_DYNAMIC) delete ptgt;
}
//+------------------------------------------------------------------+

Position *Trader::newTrade(Setup *setup) {
  //Debug4(__FUNCTION__,__LINE__,"Entered");

  Position *trade = new Position();
  trade.OrderType = OP_BUYSTOP;
  trade.LotSize = sizer.lotSize(1);
  trade.Symbol = setup.symbol;
  trade.Side = (trade.LotSize >= 0 ? Long : Short);

  int oneR = initRisk.getInPips(trade);
  double entryPrice = (setup.side==Long ? entry.entryPriceLong(EntryModel) : entry.entryPriceShort(EntryModel));

  trade.IsPending = true;
  trade.OpenPrice = entryPrice;

  if(exitMgr.useStopLoss) {
    double stopLoss =  (setup.side==Long ? entryPrice - oneR*points2decimal_factor(setup.symbol) : entryPrice + oneR*points2decimal_factor(setup.symbol));
    trade.StopPrice = stopLoss;
  }
  
  trade.Symbol = setup.symbol;
  trade.OneRpips = oneR;
  trade.Reference = __FILE__;
  trade.Magic = magic.get(setup.strategyName,oneR);
  trade.TakeProfitPrice = ptgt.getTargetPrice(trade,ProfitTargetModel);
  trade.RewardPips = int((trade.TakeProfitPrice-entryPrice)*decimal2points_factor(setup.symbol));
  
  return(trade);
};

double Trader::calcStopLoss(Position *pos) {
  double newStopLoss;
  newStopLoss = exitMgr.getTrailingStop(pos);
  if(newStopLoss > 0) {
    pos.StopPrice = newStopLoss;
    return(newStopLoss);
  }
  return(NULL);
}
