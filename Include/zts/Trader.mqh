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
}
//+------------------------------------------------------------------+

Position *Trader::newTrade(Setup *setup) {
  Position *trade = new Position();
  //trade.LotSize
  //trade.Symbol = setup.symbol;
  //trade.OrderType
  //trade.LotSize
  //trade.OpenPrice
  //trade.StopPrice
  //trade.TakeProfitPrice
  //trade.Reference
  //trade.Magic
  /**
  symbolPrefix + trade.Symbol + symbolSuffix, 
                      trade.OrderType,
                      trade.LotSize,
                      trade.OpenPrice,
                      0,    //slippage
                      trade.StopPrice,  //stop loss
                      trade.TakeProfitPrice,  //take profit
                      trade.Reference,   //smz comment
                      trade.Magic);   // magic
  }
  **/
  
  int oneR = initRisk.getInPips(OneRmodel,setup.symbol);
  double entryPrice = (setup.side==Long ? entry.entryPriceLong(EntryModel) : entry.entryPriceShort(EntryModel));
  double stopLoss =  (setup.side==Long ? entryPrice - oneR*points2decimal_factor(setup.symbol) : entryPrice + oneR*points2decimal_factor(setup.symbol));

  trade.OrderType = OP_BUYSTOP;
  trade.LotSize = sizer.lotSize(1);
  trade.Side = (trade.LotSize >= 0 ? Long : Short);
  trade.IsPending = true;
  trade.OpenPrice = entryPrice;
  trade.StopPrice = stopLoss;
  trade.Symbol = setup.symbol;
  trade.OneRpips = oneR;
  trade.RewardPips = (trade.TakeProfitPrice-entryPrice)*decimal2points_factor(setup.symbol);
  trade.Reference = __FILE__;
  trade.Magic = magic.get("RSI",oneR);
  trade.TakeProfitPrice = ptgt.getLongTarget(trade,ProfitTargetModel);
  Print(__FUNCTION__+"("+__LINE__+"): trade  ="+trade.inspect());
  
  return(trade);
};

