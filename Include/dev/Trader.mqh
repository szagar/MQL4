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
#include <dev\SetupBase.mqh>
#include <dev\setupStruct.mqh>
#include <dev\MagicNumber.mqh>
#include <dev\PriceModels.mqh>
#include <dev\PriceModelsFake.mqh>

class Trader {
private:
  PositionSizer      *sizer;
  MagicNumber        *magic;
  PriceModelsBase    *price;
  ExitManager        *exitMgr;
  InitialRisk        *initRisk;
  ProfitTargetModels *profitTgt;
public:
  Trader(ExitManager*,InitialRisk*,ProfitTargetModels*);
  ~Trader();
  
  Position *newTrade(SetupBase*);
  Position *createTrade(SetupStruct*);
  Position *newStopEntry(SetupStruct*);
  //Position *newLimitEntry(Setup *setup);
  Position *newLimitEntry(Enum_SIDE side,double limitPrice=NULL);

  double calcStopLoss(Position *);
  int enterCurrentMarket(Enum_SIDE);
  int stopEntryOrder(Enum_SIDE);
  void closeOpenPositions(Enum_SIDE,int);
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

Position *Trader::newTrade(SetupBase *setup) {
  Debug(__FUNCTION__,__LINE__,"Entered");

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
  Info2(__FUNCTION__,__LINE__,"strategyName="+setup.strategyName);
  if(StringCompare(setup.strategyName,"RboSetup")==0) {
    Info2(__FUNCTION__,__LINE__,"rboPrice="+DoubleToStr(setup.rboPrice,Digits));
    entryPrice = setup.rboPrice;
  }

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
  if(exitMgr.useTakeProfit) 
    trade.TakeProfitPrice = profitTgt.getTargetPrice(trade,PT_Model);
  trade.RewardPips = int((trade.TakeProfitPrice-entryPrice)*trade.SideX*PipFact);
  
  return(trade);
};

Position *Trader::newLimitEntry(Enum_SIDE side,double limitPrice=NULL) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  SetupStruct *setup = new SetupStruct();
  setup.symbol = Symbol();
  setup.side = side;
  if(!limitPrice) limitPrice = price.entryPrice(setup,PM_BidAsk);
  setup.limitPrice = limitPrice;
  setup.entryPrice = limitPrice;
  setup.sideX = 1;
  if(side == Long) 
    setup.orderType = OP_BUYLIMIT;
  if(side == Short) {
    setup.orderType = OP_SELLLIMIT;
    setup.sideX = -1;
  }  
  //setup.IsPending = true;
  setup.oneRpips = initRisk.getInPips(setup);

  Position *trade = createTrade(setup);
  return(trade);
}

Position *Trader::createTrade(SetupStruct *setup) {
  Position *trade = new Position();
  trade.Symbol = setup.symbol;
  trade.OpenPrice = setup.entryPrice;
  if(exitMgr.useStopLoss)
    trade.StopPrice = (setup.side==Long ? trade.OpenPrice - setup.oneRpips*PipSize :
                                          trade.OpenPrice + setup.oneRpips*PipSize);
  trade.Symbol = setup.symbol;
  trade.OneRpips = setup.oneRpips;
  trade.LotSize = sizer.lotSize(trade);
  trade.Reference = __FILE__;
  trade.Magic = magic.get(setup.strategyName,setup.oneRpips);
  if(exitMgr.useTakeProfit) 
    trade.TakeProfitPrice = profitTgt.getTargetPrice(trade,PT_Model);
  trade.RewardPips = int((trade.TakeProfitPrice-setup.entryPrice)*trade.SideX*PipFact);
  
  return(trade);
}

Position *Trader::newStopEntry(SetupStruct *setup) {
  Debug(__FUNCTION__,__LINE__,"Entered");

  Position *trade = new Position();
  if(setup.side == Long) {
    trade.OrderType = OP_BUYSTOP;
    trade.Side = setup.side;
    trade.SideX = 1;
  }
  if(setup.side == Short) {
    trade.OrderType = OP_SELLSTOP;
    trade.Side = setup.side;
    trade.SideX = -1;
  }

  double entryPrice = //price.entryPrice(trade);  

  trade.IsPending = true;
  
  int oneR = initRisk.getInPips(trade);

  trade.Symbol = setup.symbol;
  trade.OpenPrice = entryPrice;
  if(exitMgr.useStopLoss)
    trade.StopPrice = (setup.side==Long ? trade.OpenPrice - oneR*PipSize :
                                          trade.OpenPrice + oneR*PipSize);
  trade.Symbol = setup.symbol;
  trade.OneRpips = oneR;
  trade.LotSize = sizer.lotSize(trade);
  trade.Reference = __FILE__;
  trade.Magic = magic.get(setup.strategyName,oneR);
  if(exitMgr.useTakeProfit) 
    trade.TakeProfitPrice = profitTgt.getTargetPrice(trade,PT_Model);
  trade.RewardPips = int((trade.TakeProfitPrice-entryPrice)*trade.SideX*PipFact);
  
  return(trade);
};

double Trader::calcStopLoss(Position *pos) {
  Debug(__FUNCTION__,__LINE__,"Entered");
  double newStopLoss;
  double px = iClose(NULL,0,1);
  if(px-OrderOpenPrice()>exitMgr.pips2startTS(pos)*P2D)
    return(NULL);
  newStopLoss = exitMgr.getTrailingStop(pos);
  if(newStopLoss > 0) {
    pos.StopPrice = newStopLoss;
    return(newStopLoss);
  }
  return(NULL);
}

int Trader::enterCurrentMarket(Enum_SIDE side) {
  SetupStruct *setup = new SetupStruct();
  
  setup.side = side;
  setup.oneRpips = initRisk.getInPips(setup);

  Position *trade = createTrade(setup);
  if (CheckPointer(setup)    == POINTER_DYNAMIC) delete setup;

  if(trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
    Info("Trade did not meet min reward-to-risk ratio");
    if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
      return(-1);
  }
  broker.CreateOrder(trade);
  if (CheckPointer(trade)    == POINTER_DYNAMIC) delete trade;
  return(0);
}

int Trader::stopEntryOrder(Enum_SIDE side) {
  Info2(__FUNCTION__,__LINE__,"Entered.");
  SetupStruct *setup = new SetupStruct();
  setup.symbol = Symbol();
  setup.side = side;
  setup.oneRpips = initRisk.getInPips(setup);
  
  Position *trade = createTrade(setup);
  if (CheckPointer(setup)    == POINTER_DYNAMIC) delete setup;

  Info2(__FUNCTION__,__LINE__,"R2R="+NormalizeDouble(trade.RewardPips/trade.OneRpips,2));
  if(trade.RewardPips/trade.OneRpips < MinReward2RiskRatio) {
    Info("Trade did not meet min reward-to-risk ratio");
    if (CheckPointer(trade) == POINTER_DYNAMIC) delete trade;
      return(-1);
  }
  broker.CreateOrder(trade);
  if (CheckPointer(trade)    == POINTER_DYNAMIC) delete trade;
  return(0);
}

void Trader::closeOpenPositions(Enum_SIDE side, int magicN=0) {
  broker.closeOpenTrades(Symbol(),side,magicN);
}
