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
#include <zts\Setup.mqh>
#include <zts\MagicNumber.mqh>
#include <zts\EntryModels.mqh>
#include <zts\ProfitTargetModels.mqh>

class Trader {
private:
  PositionSizer *sizer;
  InitialRisk *initRisk;
  MagicNumber *magic;
  EntryModels *entry;
  ProfitTargetModels *ptgt;
  
public:
  Trader();
  ~Trader();
  
  Position *newTrade(Setup*);
};

Trader::Trader() {
  sizer = new PositionSizer();
  initRisk = new InitialRisk();
  magic = new MagicNumber();
  entry = new EntryModels(1);
  ptgt = new ProfitTargetModels();
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
  Debug4(__FUNCTION__,__LINE__,"Entered");

  Position *trade = new Position();
  trade.OrderType = OP_BUYSTOP;
  trade.LotSize = sizer.lotSize(1);
  trade.Symbol = setup.symbol;
  trade.Side = (trade.LotSize >= 0 ? Long : Short);
  Debug4(__FUNCTION__,__LINE__,"trade.LotSize="+DoubleToStr(trade.LotSize,2)+"  trade.Side="+EnumToString(trade.Side));

  Debug4(__FUNCTION__,__LINE__,"oneR = initRisk.getInPips("+EnumToString(OneRmodel)+","+setup.symbol+");");
  int oneR = initRisk.getInPips(OneRmodel,trade);
  Debug4(__FUNCTION__,__LINE__,"oneR = "+DoubleToStr(oneR,Digits));
  double entryPrice = (setup.side==Long ? entry.entryPriceLong(EntryModel) : entry.entryPriceShort(EntryModel));
  Debug4(__FUNCTION__,__LINE__,"entryPrice = "+DoubleToStr(entryPrice,Digits));

  trade.IsPending = true;
  trade.OpenPrice = entryPrice;

  if(UseStopLoss) {
    double stopLoss =  (setup.side==Long ? entryPrice - oneR*points2decimal_factor(setup.symbol) : entryPrice + oneR*points2decimal_factor(setup.symbol));
    Debug4(__FUNCTION__,__LINE__,"stopLoss = "+DoubleToStr(stopLoss,Digits));
    trade.StopPrice = stopLoss;
  }
  
  trade.Symbol = setup.symbol;
  trade.OneRpips = oneR;
  trade.Reference = __FILE__;
  trade.Magic = magic.get(setup.strategyName,oneR);
  trade.TakeProfitPrice = ptgt.getLongTarget(trade,ProfitTargetModel);
  trade.RewardPips = int((trade.TakeProfitPrice-entryPrice)*decimal2points_factor(setup.symbol));
  Debug4(__FUNCTION__,__LINE__,"trade  ="+trade.inspect());
  
  return(trade);
};

